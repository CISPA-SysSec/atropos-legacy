"""
    A Node stores the data describing a single request-response pair. 
"""
from __future__ import annotations

import jsonpickle

from typing           import Dict, Any, Union, Optional
from urllib.parse     import ParseResult, urlparse, urlunparse, urlencode
from aiohttp.typedefs import CIMultiDictProxy


from .environment     import env
from .misc            import object_to_tuple, query_to_dict, calc_weighted_difference, to_bucket, parse_headers, parse_file
from .types           import OutputMethod, Params, Policy, XSSConfidence, UrlType, HTTPMethod, FuzzerException, CFGTuple, CFG

# post (and maybe get) parameters can get pretty huge. for instance when sending a file
# via post. Or sometimes a parameter can get reescaped in every request/response cycle
# making it grow infinitely long. This value crops all parameters to this max size in characters.
MAX_PARAMETER_SIZE = 200

# for calculating the node rank
COVER_SCORE_RWEIGHT   =  0.25
MUTATED_SCORE_RWEIGHT =  0.25
SINK_SCORE_RWEIGHT    =  0.25
EXEC_TIME_RWEIGHT     = -0.00
NODE_SIZE_RWEIGHT     = -0.00
PICKED_SCORE_RWEIGHT  = -0.60

# for calculating the lightest node
EXEC_TIME_LWEIGHT = -0.60
NODE_SIZE_LWEIGHT = -0.30
UNCERTAINTY_THRESH = 0.10

class Node:
    def __init__(self,
                 url: Union[str|UrlType],
                 method: HTTPMethod,
                 params: Optional[Params] = None,
                 parent_request: Optional[Node] = None,
                 exec_time: float = 0,
                 label: str = ""):

        if not params:
            params = {}
            
        params[HTTPMethod.GET] = params.get(HTTPMethod.GET, {})
        params[HTTPMethod.POST] = params.get(HTTPMethod.POST, {})

        if isinstance(url, str):
            url = urlparse(url)

        if isinstance(url, ParseResult):
            # Parse a query string to dict of its parameters.
            get_params = query_to_dict(url.query)
            params[HTTPMethod.GET].update(get_params)
            self.params = params

            # Convert the url object back to string without the query.
            self._url: str = urlunparse(url._replace(query=''))
        else:
            raise FuzzerException(f"Invalid url type {str(type(url))}")

        self._method = method

        if method == HTTPMethod.GET and self.params[HTTPMethod.POST]:
            raise FuzzerException("Something went wrong. A GET request cannot have POST parameters")

        self.exec_time: float = exec_time
        self.picked_score: int = 0  # how many times it has been chosen for further mutation
        self.parent_request = parent_request  # coverage score of the parent (node that we got mutated from)
        self.has_sinks = False

        self.ref_count: int = 0
        self._xss_confidence = XSSConfidence['NONE']

        self.label = label

        # instrumentation related metadata
        self._cover_score_xor: int = 0  # coverage score (xor label count)
        self._cover_score_single: int = 0  # coverage score (simple label count)

    @property
    def url(self) -> str:
        return self._url

    @property
    def full_url(self) -> str:
        if not hasattr(self, '_full_url'):
            self._full_url = urlunparse(self.url_object)

        return self._full_url

    @property
    def url_object(self) -> UrlType:
        if not hasattr(self, '_url_object'):
            url_obj = urlparse(self._url)
            query = urlencode(self.params[HTTPMethod.GET], doseq=True)
            self._url_object = url_obj._replace(query=query)
        
        return self._url_object

    @property
    def method(self) -> HTTPMethod:
        return self._method

    @property
    def is_mutated(self) -> bool:
        if self.parent_request:
            return True
        else:
            return False

    @property
    def sink_score(self) -> int:
        return int(self.has_sinks)

    @property
    def params(self) -> Params:
        return self._params

    @property
    def size(self):
        if not hasattr(self, '_size'):
            size = 0
            for (_, params) in self._params.items():
                for key in params:
                    size += len(key) + len(str(params[key]))
            self._size = size

        return self._size

    @params.setter
    def params(self, new_value: Params) -> Node:
        self._params = new_value

        # trim all parameters to a maximum allowed length
        for (_, params) in self._params.items():
            for key in params:
                length = len(params[key])
                if length > MAX_PARAMETER_SIZE:
                    params[key] = params[key][length - MAX_PARAMETER_SIZE:]

        # force recalculation of the following
        # attr since they depend on params
        self.__dict__.pop('_url_object',None)
        self.__dict__.pop('_full_url',None)
        self.__dict__.pop('_size',None)
        self.__dict__.pop('_json',None)
        self.__dict__.pop('_hash',None)

        return self

    @property
    def xss_confidence(self):
        return self._xss_confidence

    @xss_confidence.setter
    def xss_confidence(self, value: XSSConfidence) -> Node:
        self._xss_confidence = value
        # force refresh of json
        self.__dict__.pop('_json',None)

        return self

    @property
    def cover_score(self):
        if env.instrument_args.policy == Policy.EDGE:
            score = self._cover_score_xor
            count = env.instrument_args.edges
        else:
            score = self._cover_score_single
            count = env.instrument_args.basic_blocks

        return 100 * score / count

    @property
    def cover_score_raw(self):
        if env.instrument_args.policy == Policy.NODE:
            return self._cover_score_single
        else:
            return self._cover_score_xor

    @property
    def mutated_score(self) -> int:
        if not self.is_mutated:
            return 0

        return self.cover_score_raw - self.parent_request.cover_score_raw

    @property
    def json(self) -> str:
        """
            The json format of the node. Note that not all the attributes
            are outputted to the json. See Node.__getstate__
        """
        if not hasattr(self, '_json'):
            self._json = jsonpickle.encode(self, unpicklable=False)
        
        return self._json

    def parse_instrumentation(self, 
                              headers: CIMultiDictProxy[str],
                              worker_id: str = "") -> CFGTuple:
        """
           Parses the instrumentation feedback from a request. 
        """
        cfg_xor: CFG = {}
        cfg_single: CFG = {}
        instrument_args = env.instrument_args
        
        iterator = None
        if instrument_args.output_method == OutputMethod.HTTP:
            iterator = parse_headers(headers)

        elif instrument_args.output_method == OutputMethod.FILE:
            iterator = parse_file("/var/instr/map." + worker_id)

        if instrument_args.policy == Policy.EDGE or \
           instrument_args.policy == Policy.NODE:
           
            cfg: CFG = {}
            for (label, hit_count) in iterator:
                cfg[label] = to_bucket(int(hit_count))

            if instrument_args.policy == Policy.EDGE:
                cfg_xor = cfg
            else:
                cfg_single = cfg

        elif instrument_args.policy == Policy.NODE_EDGE:
            for (label, value) in iterator:
                (xor, single) = map(int, value.split('-'))
                if xor > 0:
                    cfg_xor[label] = to_bucket(xor)
                if single > 0:
                    cfg_single[label] = to_bucket(single)

        self._cover_score_xor = len(cfg_xor)
        self._cover_score_single = len(cfg_single)

        # force refresh of json format
        self.__dict__.pop('_json',None)

        return CFGTuple(xor_cfg=cfg_xor,
                        single_cfg=cfg_single)

    def is_lighter_than(self, node2: Node) -> bool:
        """
            Returns whether Self Node is 'lighter' than node2 Node.
            Lighter means has lower execution time and/or smaller parameter size.
            A weighted difference is calculated using these two measurements.
        """
        if not isinstance(node2, type(self)):
            raise NotImplementedError()

        weighted_diff = calc_weighted_difference(node2.exec_time, self.exec_time,   EXEC_TIME_LWEIGHT) + \
                        calc_weighted_difference(node2.size,      self.size,        NODE_SIZE_LWEIGHT)

        is_lighter_than_node2: bool = weighted_diff < 0

        # if self is lighter than node2 then
        # it will be replaced with node2 in global map
        # since replacing nodes is expensive and response time
        # can vary to some degree, we provide the UNCERTAINTY_THRESH
        # to guard against that (i.e. only if self node is significantly lighter than node2)
        if is_lighter_than_node2 and abs(weighted_diff) < UNCERTAINTY_THRESH:
            return False
        
        return is_lighter_than_node2

    def __cmp__(self, node2: Node) -> float:
        """
            Defines the ordering of any two nodes (used in sort(), bisect.insort(), heapq.heappush())
            Because we use a min-heap in NodeIterator, a smaller node will actually have higher priority
            in the heap tree. Thus in this ordering smaller nodes are more favorable
        """
        if not isinstance(node2, type(self)):
            raise NotImplementedError()

        return calc_weighted_difference(node2.cover_score_raw,      self.cover_score_raw,      COVER_SCORE_RWEIGHT)    + \
               calc_weighted_difference(node2.exec_time,            self.exec_time,            EXEC_TIME_RWEIGHT)      + \
               calc_weighted_difference(node2.size,                 self.size,                 NODE_SIZE_RWEIGHT)      + \
               calc_weighted_difference(node2.picked_score,         self.picked_score,         PICKED_SCORE_RWEIGHT)   + \
               calc_weighted_difference(node2.mutated_score,        self.mutated_score,        MUTATED_SCORE_RWEIGHT)  + \
               calc_weighted_difference(node2.sink_score,           self.sink_score,           SINK_SCORE_RWEIGHT)
        
    def __lt__(self, node2: Node) -> bool:
        return self.__cmp__(node2) < 0

    def __gt__(self, node2: Node) -> bool:
        return self.__cmp__(node2) > 0

    def __eq__(self, node2: Node) -> bool:
        """
            Compare if equal. (Needed in order for Node to be part of a Set)
            Uses their hash.
        """
        if not isinstance(node2, type(self)): 
            raise NotImplementedError()

        return self.__hash__() == node2.__hash__()

    def __hash__(self) -> int:
        """
            The hash of the node. (Needed in order for Node to be part of a Set)
            It is made from the immutable (not enforced) parts of the node.
        """
        if not hasattr(self, '_hash'):
            if env.args.uniq_frag:
                url = self.url
            else:
                # remove fragment
                url = urlparse(self.url)._replace(fragment='')
                url = urlunparse(url)

            self._hash = hash((url, self.method, object_to_tuple(self.params)))

        return self._hash

    def __getstate__(self) -> Dict[str, Any]:
        """
            Tell jsonpickle which attributes from the Node
            to output in the json
        """

        state = {}

        state['url'] = self.url
        state['method'] = self.method.name
        state['params'] = self.params
        state['xss_confidence'] = self.xss_confidence.name
        state['cover_score'] = str(f"{self.cover_score:.3f}")
        state['mutated_score'] = self.mutated_score
        state['exec_time'] = str(f"{self.exec_time:.3f}")

        return state

    def __str__(self) -> str:
        """
            Defines the printable format of a node
        """
        return self.json
        
    def __repr__(self) -> str:
        """
            Defines the Python-like string format of the node
            TODO: Create an Python-acceptable string format of the Node
                  instead of calling self.__str__()
        """
        return self.json
