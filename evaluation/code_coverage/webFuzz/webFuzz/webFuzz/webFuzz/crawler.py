import re
import json

from typing     import Dict, List, Set, Optional
from datetime   import datetime

from .types     import HTTPMethod, BlockRule, List
from .misc      import get_logger
from .node      import Node

CRAWLER_PER_BASE_LIMIT = 2000

Hash = int
Url = str
BaseURLCounter = Dict[HTTPMethod, Dict[Url, int]]

class Crawler:
    def __init__(self, 
                 init_seed: Optional[Set[Node]] = None,
                 seed_file: Optional[str] = None,
                 block_rules: List[BlockRule] = []):

        self._crawler_unseen: Set[Node] = set()

        if init_seed:
            self._crawler_unseen.update(init_seed)
            Crawler.store_init_seed(init_seed)

        if seed_file:
            self._crawler_unseen.update(Crawler.parse_init_seed(seed_file))

        self._block_rules = block_rules
        self._crawler_seen_full: Set[Hash] = set()
        self._crawler_seen_base: BaseURLCounter = { 
            HTTPMethod.GET: {}, 
            HTTPMethod.POST: {} 
        }

    @staticmethod
    def parse_init_seed(filename:str) -> Set[Node]:
        logger = get_logger(__name__)

        nodes = set()

        with open(filename, "r") as f:
            data = json.loads(f.read())
        
        for entry in data:
            method = HTTPMethod[entry["method"].upper()]
            params = {
                HTTPMethod.GET: entry["params"]["GET"],
                HTTPMethod.POST: entry["params"]["POST"]
            }
            nodes.add(Node(entry["url"], method, params))
    
        logger.info("Seed file number of entries %d", len(nodes))
        logger.debug("Read seed file as %s", nodes)

        return nodes

    @staticmethod
    def store_init_seed(seed: Set[Node]) -> None:
        logger = get_logger(__name__)
        entries = []

        dt = datetime.now()
        filename = f"./seeds/webFuzz_seed" + \
                   f"_{dt.day}-{dt.month}" + \
                   f"_{dt.hour}:{dt.minute}.json"

        logger.info("Writing seed to %s", filename)

        for node in seed:
            entry = {
                "url": node.url,
                "method": node.method.name,
                "params": {
                    "GET": node.params[HTTPMethod.GET],
                    "POST": node.params[HTTPMethod.POST]
                }
            }
            entries.append(entry)

        with open(filename, "w+") as f:
            json.dump(entries, f, indent=3)

    @property
    def pending_requests(self) -> int:
        return len(self._crawler_unseen)

    @staticmethod
    def _is_match(rule: BlockRule, node: Node) -> bool:
        if rule.method and not rule.method == node.method:
            return False

        if not re.search(rule.url, node.url, re.IGNORECASE):
            return False
        
        if not rule.key and not rule.val:
            return True

        for method in node.params:
            for key in node.params[method]:
                if not re.search(rule.key, key, re.IGNORECASE):
                    continue
                    
                for value in node.params[method][key]:
                    if re.search(rule.val, value, re.IGNORECASE):
                        return True
        
        return False

    """
        Check if the request to be sent matches the criteria of a blocked link

        :param new_request: the request that we want to check
        :type links: Node
        :return: if the request is allowed to be sent
        :rtype: bool
    """
    def _should_block(self, new_request: Node) -> bool:
        logger = get_logger(__name__)

        for rule in self._block_rules:
            if Crawler._is_match(rule, new_request):
                logger.info("Blocked %s", new_request)
                return True
               
        return False
    
    """
        Add to crawler the new links that
        have been found but check that we
        haven't already visited any one of them first

        :param links: the new links to add
        :type links: Set[Node]
        :return: the updated crawler object
        :rtype: Crawler
    """
    def __add__(self, links: Set[Node]):
        if not isinstance(links, set):
            raise NotImplementedError()

        logger = get_logger(__name__)

        if not links:
            return self

        # since we do not need to store the whole Node object
        # for keeping track which requests have been sent in the
        # past, but only their hash, we compare hashes
        # instead of nodes, and filter out already seen links
        # TODO: there must be a cleaner way to do this
        hash_of_links = set(map(lambda link: link.__hash__(), links))
        uniq_hashes = hash_of_links - self._crawler_seen_full
        uniq_links:Set[Node] = set(
            filter(
                lambda link: link.__hash__() in uniq_hashes, 
                links
            )
        )

        self._crawler_unseen = self._crawler_unseen | uniq_links

        logger.debug("New links found: %s", uniq_links)

        return self

    """
        Check if the base url of the new request did not surpass the limit.
        Each base url (without the query,fragment string) is only allowed to be sent
        in total CRAWLER_PER_BASE_LIMIT number of times. This is a simple
        way to stop urls with nonce parameter to be constantly sent

        :param new_request: the request that we want to check
        :type links: Node
        :return: if the request is allowed to be sent
        :rtype: bool
    """
    def _base_url_allows(self, new_request: Node) -> bool:
        logger = get_logger(__name__)

        base_dict = self._crawler_seen_base[new_request.method]

        if new_request.url not in base_dict:
            base_dict[new_request.url] = 0
            return True
        else:
            base_dict[new_request.url] += 1
            if base_dict[new_request.url] == CRAWLER_PER_BASE_LIMIT:
                logger.warning("Base URL %s added to blocklist", new_request.url)
            
            if base_dict[new_request.url] >= CRAWLER_PER_BASE_LIMIT:
                return False

        return True

    def __iter__(self):
       return self

    """
        Get the next node to send a request.
        A new request must firstly pass the 
        blocked link criteria, and the per base url
        limit criteria.

        :return: the next request to sent
        :rtype: Node
    """
    def __next__(self):

        while len(self._crawler_unseen) != 0:
            new_request = self._crawler_unseen.pop()

            # store only the hash in the set
            # as the whole node is not needed
            self._crawler_seen_full.add(new_request.__hash__())

            if self._should_block(new_request):
                continue

            if not self._base_url_allows(new_request):
                continue

            return new_request

        raise StopIteration
