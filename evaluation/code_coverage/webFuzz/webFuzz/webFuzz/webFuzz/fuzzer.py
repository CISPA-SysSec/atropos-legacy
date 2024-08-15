import aiohttp
import asyncio
import curses
import http.client
import json
import logging
import random
import signal
import os

from typing         import ContextManager, List, AsyncIterator, Dict
from aiohttp.client import ClientSession, TraceConfig
from urllib.parse   import urlparse
from contextlib     import asynccontextmanager

# User defined modules
from .worker        import Worker
#from .curses_menu   import Curses_menu
from .environment   import env
from .node          import Node
from .types         import Arguments, FuzzerLogger, InstrumentArgs, OutputMethod, get_logger, HTTPMethod, Statistics, ExitCode, RunMode
from .misc          import retrieve_headers, sigalarm_handler, sigint_handler, rtt_trace_config
from .mutator       import Mutator
from .node_iterator import NodeIterator
from .crawler       import Crawler
from .browser       import Browser
from .parser        import Parser
from .detector      import Detector
from .simple_menu   import Simple_menu

class Fuzzer:
    def __init__(self, args: Arguments) -> None:
        """
            Initialisation of a webFuzz instance
        """
        env.args = args

        FuzzerLogger.init_logging(args)

        logger = get_logger(__name__)
        logger.debug(args)

        self.worker_count = args.worker

        meta = json.loads(open(args.meta_file).read())
        # throws exception on invalid format
        env.instrument_args = InstrumentArgs(meta)
        logger.debug(env.instrument_args)

        if env.instrument_args.output_method == OutputMethod.HTTP:
            # expect instr. feedback in http-header form so adjust this
            http.client._MAXHEADERS = max(10000, env.instrument_args.basic_blocks) # type:ignore

        self._session_node = Node(url=urlparse(args.URL), method=HTTPMethod.GET, label="session_check")
        start_node = Node(url=urlparse(args.URL), method=HTTPMethod.GET)
        initial_seed = set([start_node])
            
        cookies = {}
        if args.proxy:
            b = Browser(args.driver_file, proxy_port=args.proxy_port)
            result = b.run_browser(start_node)

            if args.session:
                cookies = result.cookies
            if args.proxy:
                initial_seed.update(result.nodes)
        
        self.http_cookies = json.load(open(os.environ["SESSION"], "r")) #cookies
        logger.debug("Initial Seed: %s", initial_seed)

        headers = retrieve_headers()
        self.http_headers = headers

        self._crawler = Crawler(block_rules=args.block,
                                init_seed=initial_seed,
                                seed_file=args.seed_file)

        self._node_iterator = NodeIterator()
        
        self._mutator = Mutator()

        self._parser = Parser()

        self._detector = Detector()

        self.stats = Statistics(start_node)

    @asynccontextmanager
    async def http_session(cookies: Dict[str, str],
                           headers: Dict[str, str],
                           conn_count: int) -> AsyncIterator[ClientSession]:
        logger = get_logger(__name__)
        logger.info("New session to be created")

        # timeout per link in seconds
        timeout = aiohttp.ClientTimeout(total=env.args.request_timeout) # type: ignore
        trace_configs = [rtt_trace_config()]

        conn = aiohttp.TCPConnector(limit=conn_count, limit_per_host=conn_count)

        async with aiohttp.ClientSession(cookies=cookies,
                                         headers=headers,
                                         connector=conn,
                                         timeout=timeout,
                                         trace_configs=trace_configs) as s:
            yield s
    
    async def fuzzer_loop(self) -> ExitCode:
        while True:
            logger = get_logger(__name__)
            exit_code = ExitCode.NONE

            if env.args.session and not self.http_cookies:
                # b = Browser(env.args.driver_file, proxy_port=env.args.proxy_port)
                # result = b.run_browser(self._session_node)

                # self.http_cookies = result.cookies
                self.http_cookies = json.load(open(os.environ["SESSION"], "r"))

            async with Fuzzer.http_session(self.http_cookies, 
                                        self.http_headers, 
                                        self.worker_count) as s:

                logger.info("Spawning %d workers", self.worker_count)

                workers: List[asyncio.Task] = []
                for count in range(self.worker_count):
                    worker_id = str(random.randrange(10000, 1000000))
                    worker = Worker(worker_id,
                                    s,
                                    self._crawler,
                                    self._mutator,
                                    self._parser,
                                    self._detector,
                                    self._node_iterator,
                                    self._session_node,
                                    self.stats)

                    workers.append(worker.async_run())

                    if count == 0:
                        # if it is the first worker spawned
                        # wait until at least one request/response cycle is done
                        # this is needed because workers that find an empty queue exit
                        await asyncio.sleep(8)

                    if env.shutdown_signal != ExitCode.NONE:
                        break
            
                # wait for them to finish
                for worker in workers:
                    exit_code: ExitCode = await worker
            
            if exit_code == exit_code.LOGGED_OUT and env.args.session:
                # recursion depth problem here
                self.http_cookies = {}
                continue
                #return await self.fuzzer_loop()
            
            env.shutdown_signal = exit_code
            logger.warning('Shutting Down...')
            logging.shutdown()
            break

        return env.shutdown_signal

    """
        Starting point for the Fuzzer execution with simple print interface. Here you can specify
        async tasks to run *concurrently* and register async safe Signal Handlers
    """
    async def async_run(self, interface) -> ExitCode:
        loop = asyncio.get_running_loop()
        loop.add_signal_handler(signal.SIGINT, sigint_handler)
        loop.add_signal_handler(signal.SIGALRM, sigalarm_handler)

        interface_task = asyncio.create_task(interface.run(self))
        fuzzer_loop_task = asyncio.create_task(self.fuzzer_loop())

        exit_code = await fuzzer_loop_task
        await interface_task

        return exit_code

    def run(self) -> ExitCode:
        if env.args.run_mode == RunMode.SIMPLE:
            interface = Simple_menu(print_to_file=False)
        elif env.args.run_mode == RunMode.FILE:
            interface = Simple_menu(print_to_file=True)
        else:
            raise Exception("Curses interface not available")
            #interface = Curses_menu()
        
        return asyncio.run(self.async_run(interface))
