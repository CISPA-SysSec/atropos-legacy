import asyncio
import logging

from aiohttp      import ClientSession,ClientResponse
from bs4          import BeautifulSoup
from typing       import Generator, Union, Optional, Dict, Iterator, AsyncIterator
from itertools    import repeat
from contextlib   import asynccontextmanager

# User defined modules
from .environment   import env
from .node          import Node
from .types         import FuzzerLogger, get_logger, HTTPMethod, RequestStatus, Statistics, ExitCode, UnimplementedHttpMethod, InvalidContentType, InvalidHttpCode, XSSConfidence
from .misc          import iter_join, lazyFunc
from .mutator       import Mutator
from .node_iterator import NodeIterator
from .crawler       import Crawler
from .parser        import Parser
from .detector      import Detector
from .browser       import Browser

# every how many requests to check if
# we are logged in
LOGGED_IN_CHECK_INTERVAL = 50

class Worker():
    def __init__(self,
                 id_: str, 
                 session: ClientSession, 
                 crawler: Crawler, 
                 mutator: Mutator,
                 parser: Parser,
                 detector: Detector,
                 iterator: NodeIterator,
                 session_node: Node,
                 statistics: Statistics):

        self.id = id_
        self._session = session
        self._crawler = crawler
        self._mutator = mutator
        self._parser = parser
        self._detector = detector
        self._node_iterator = iterator
        self._session_node = session_node
        self._stats = statistics

    @property
    def asyncio_task(self) -> Optional[asyncio.Task]:
        if hasattr(self, "_task"):
            return self._task
        else:
            return None

    def async_run(self):
        self._task = asyncio.create_task(self.run_worker())
        return self._task

    def update_stats(self, current_node: Node):
        self._stats.total_cover_score = self._node_iterator.total_cover_score
        self._stats.current_node = current_node
        self._stats.crawler_pending_urls = self._crawler.pending_requests
        self._stats.total_xss = self._detector.xss_count

    @staticmethod
    def has_catchphrase(raw_html: str, catchphrase: str) -> bool:
        if not catchphrase:
            return True

        if catchphrase in raw_html:
            return True

        return False

    @asynccontextmanager
    async def http_send(self, new_request: Node) -> AsyncIterator[ClientResponse]:
        logger = get_logger(__name__, self.id)

        if new_request.method == HTTPMethod.GET:
            aiohttp_send = self._session.get
        elif new_request.method == HTTPMethod.POST:
            aiohttp_send = self._session.post
        else:
            logger.error("Unimplemented HTTP method")
            raise UnimplementedHttpMethod(new_request.method)

        logger.info("sending request: %s", new_request.url)

        async with aiohttp_send(new_request.url,
                                headers={ 'REQ-ID' : self.id},
                                params=new_request.params[HTTPMethod.GET],
                                data=new_request.params[HTTPMethod.POST],
                                trace_request_ctx=new_request) as r:

            self._stats.total_requests += 1

            if r.content_type and r.content_type.lower() != 'text/html':
                raise InvalidContentType(r.content_type)

            if r.status >= 400:
                logger.info('Got code %d from %s', r.status, r.url)

                if env.args.ignore_404 and r.status == 404:
                    raise InvalidHttpCode(404)

                if env.args.ignore_4xx:
                    raise InvalidHttpCode(r.status)

            yield r

    async def process_req(self, request: Node) -> RequestStatus:
        logger = get_logger(__name__, self.id)

        async with self.http_send(request) as r:
            raw_html: str = await r.text()

            logger.debug(raw_html)

            if request.label == 'session_check':
                # special node to check if we are logged in
                if Worker.has_catchphrase(raw_html, env.args.catch_phrase):
                    logger.info("Success, we are still logged in")
                    return RequestStatus.SUCCESS_FOUND_PHRASE

            # html5lib parser is the most identical method to how browsers parse HTMLs
            soup = lazyFunc(BeautifulSoup, raw_html, "html5lib")

            if self._detector.xss_precheck(raw_html):
                self._detector.xss_scanner(request, next(soup))

            cfg = request.parse_instrumentation(r.headers, self.id)

            status = RequestStatus.SUCCESS_NOT_INTERESTING
            
            self._node_iterator.add(request, cfg)
            links = self._parser.parse(request, next(soup))
            self._crawler += links

            status = RequestStatus.SUCCESS_INTERESTING

            self.update_stats(request)

            logger.info("Request Completed: %s", request)
            if (request._xss_confidence > XSSConfidence['NONE']):
                logger.warning("Suspicious request %s", request)

            return status
    
    async def run_worker(self) -> ExitCode:
        logger = get_logger(__name__, self.id)
        logger.info("Worker reporting Active")

        if env.args.catch_phrase:
            periodic = repeat(self._session_node)
        else:
            # create an empty iterator
            periodic = repeat(None, 0)

        for (src, new_request) in iter_join(primary=self._crawler,
                                            secondary=self._node_iterator, 
                                            periodic=periodic,
                                            interval=LOGGED_IN_CHECK_INTERVAL):
            if src == self._crawler:
                logger.info("Chosen an unvisited node")

            elif src == self._node_iterator:
                # this request isn't new i.e. it came from NodeIterator
                # thus needs to be mutated first
                new_request = self._mutator.mutate(new_request, 
                                                   self._node_iterator.node_list)
                logger.info("Chosen a mutated node")

            try:
                return_code = await self.process_req(new_request)
            except Exception as e:
                if env.args.http_error_at_info:
                    logger.info(e, exc_info=False)
                else:
                    logger.warning(e, exc_info=False)

                return_code = RequestStatus.UNSUCCESSFUL_REQUEST
            
            if src == periodic and \
                return_code != RequestStatus.SUCCESS_FOUND_PHRASE:
                logger.warning("Fuzzer has been logged out...")

                return ExitCode.LOGGED_OUT

            if env.shutdown_signal != ExitCode.NONE:
                return env.shutdown_signal

        logger.error("Aborting due to lack of fuzz targets")
        return ExitCode.EMPTY_QUEUE
