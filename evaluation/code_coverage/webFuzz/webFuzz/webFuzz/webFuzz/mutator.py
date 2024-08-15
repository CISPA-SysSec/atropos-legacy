import random
import logging
import re
import string
import copy

from typing         import Callable, List, Optional, Tuple, NamedTuple
from math           import ceil
from os.path        import dirname

# User defined modules
from .node          import Node
from .types         import HTTPMethod, Params, get_logger

# Weights that govern how often a mutation
# function is called. These should sum to 100
FREQ_STRXSS_PAYLOAD  = 0
FREQ_XSS_PAYLOAD     = 20
FREQ_TYPE_ALTER      = 5
FREQ_RAND_TEXT       = 35
FREQ_SYNTAX_TOKEN    = 20
FREQ_SKIP_PARAM      = 20 

# Smaller values indicate higher frequency
FREQ_CLEAR_PARAM     = 5 

# these should remain as is
HEADS = 1
TAILS = 2

class Kind(NamedTuple):
    weight: int
    payloads: List[str]

class MutateFunc(NamedTuple):
    id: int
    weight: int
    func: Callable

class Payloads(NamedTuple):
    payloads: List[Kind]

    @property
    def weights(self) -> List[int]:
        weights = []

        for f in self.payloads:
            weights.append(f.weight)

        return weights

    @property
    def payload(self) -> str:
        p = random.choices(self.payloads,
                           weights=self.weights, k=1)[0]
        
        return random.choice(p.payloads)

class MutateFunctions(NamedTuple):
    funcs: List[MutateFunc]

    @property
    def functions(self) -> List[Callable]:
        funcs = []
        for f in self.funcs:
            funcs.append(f.func)
        return funcs

    @property
    def weights(self):
        weights = []
        for f in self.funcs:
            weights.append(f.weight)
        return weights

    @property
    def mutator(self) -> Callable:
        func = random.choices(self.functions,
                              weights=self.weights,
                              k=1)[0]
        return func

def read_tokens(filename:str) -> List[str]:
    with open(dirname(__file__) + "/" + filename) as fl:
        lines = fl.read().split('\n')
        return list(filter(lambda l: l, lines))

class Mutator:
    def __init__(self):
    
        self.xss_payloads: Payloads = Payloads([
            Kind(weight=30, payloads=read_tokens("Payloads/XSS/attributes")),
            Kind(weight=50, payloads=read_tokens("Payloads/XSS/dirty")),
            Kind(weight=20, payloads=read_tokens("Payloads/XSS/well_formed"))
        ])
     
        self.syntax_tokens: Payloads = Payloads([
            Kind(weight=30, payloads=read_tokens("Payloads/Syntax/html")),
            Kind(weight=30, payloads=read_tokens("Payloads/Syntax/php")),
            Kind(weight=40, payloads=read_tokens("Payloads/Syntax/js"))
        ])

        # register mutating functions
        self.per_param_mutators = MutateFunctions(funcs=[
            MutateFunc(1, FREQ_STRXSS_PAYLOAD, self.add_strxss_payload),
            MutateFunc(2, FREQ_XSS_PAYLOAD, self.add_xss_payload),
            MutateFunc(3, FREQ_TYPE_ALTER, self.alter_type),
            MutateFunc(4, FREQ_RAND_TEXT, self.add_random_text),
            MutateFunc(5, FREQ_SYNTAX_TOKEN, self.add_syntax_token),
            MutateFunc(6, FREQ_SKIP_PARAM, self.skip_param)
        ])

    def mutate(self, from_node: Node, node_list: List[Node]) -> Node:
        """
            Returns a new Node with mutated input parameters
        """
        logger = get_logger(__name__)
        logger.debug("Start node: %s", from_node)

        if from_node.size == 0:
            # does not have any parameters
            new_params = self.cross_over(from_node, node_list)
        else:
            choice = random.choices([self.per_param_mutate, self.all_param_mutate], 
                                    weights=[80,20], 
                                    k=1)[0]

            new_params = choice(from_node, node_list)

        new_node = Node(url=from_node.url,
                        method=from_node.method,
                        params=new_params,
                        parent_request=from_node)

        logger.debug("Mutated node: %s", new_node)
        return new_node
    
    def per_param_mutate(self, from_node: Node, node_list: List[Node]) -> Params:
        logger = logging.getLogger(__name__)
        logger.debug("Mutating each parameter")
        
        params: Params = {}

        for param_type in [HTTPMethod.GET, HTTPMethod.POST]:
            params[param_type] = copy.deepcopy(from_node.params[param_type]) 

            for key, value in from_node.params[param_type].items():
                if (random.randint(0, FREQ_CLEAR_PARAM) == 0):
                    value = ""

                (param, val) = self.per_param_mutators.mutator(key, value)

                if param != key:
                    # delete the original parameter if mutated parameter name is different
                    del params[param_type][key]

                # set the new parameter
                params[param_type][param] = val
                logger.debug("Mutated (%s,%s) to (%s,%s)",key, value, param, val)

        return params

    def all_param_mutate(self, from_node:Node, node_list: List[Node]) -> Params:
        logger = logging.getLogger(__name__)
        logger.debug("Mutating all parameters")

        functions = [self.cross_over]

        return random.choice(functions)(from_node, node_list)

    @staticmethod
    def select_favourable_node(node_list: List[Node], 
                               start_node: Node, 
                               cross_type: HTTPMethod) -> Optional[Node]:
        if len(node_list) == 0:
            return None

        len_params_self = len(start_node.params[cross_type])

        cross_node = node_list[0]
        for node in node_list:

            len_params_node = len(node.params[cross_type])
            
            if len_params_node > len(cross_node.params[cross_type]) and \
                 node.url != start_node.url:
                cross_node = node
                break
            elif len_params_node >= ceil(len_params_self/2):
                cross_node = node
        
        return cross_node

    @staticmethod
    def cross_over(from_node:Node, node_list: List[Node]) -> Params:
        """
            Cross over the parameters of two different
            nodes to form a new one. Note that the url and method
            of the new mutated node that will be created will be from
            new_node. Only its parameters will get mixed with the parameters
            of another node.
        """
        logger = logging.getLogger(__name__)
        logger.debug("Mutate fun cross-over")

        params: Params = {}

        # this is a double cross-over
        # cross-over between get and post parameters
        # at each cross-over a new link is chosen
        for param_type in [HTTPMethod.GET, HTTPMethod.POST]:
            params[param_type] = copy.deepcopy(from_node.params[param_type]) 

            if from_node.method == HTTPMethod.GET and param_type == HTTPMethod.POST:
                # GET requests should not have post parameters
                continue

            cross_node = Mutator.select_favourable_node(node_list, from_node, param_type)
            logger.debug("Selected cross-over node as %s")

            if cross_node is None:
                continue

            # merge their parameters
            params[param_type].update(cross_node.params[param_type])

        return params

    @staticmethod
    def skip_param(param: str, val: List[str]) -> Tuple[str, List[str]]:
        logger = logging.getLogger(__name__)
        # Mutation function that leaves parameter name and value intact
        # Useful when certain parameters need to remain unchanged

        logger.debug("Not mutating this parameter %s with value %s", param, val)

        return (param, val)

    @staticmethod
    def alter_type(param:str, val: List[str]) -> Tuple[str, List[str]]:
        """
            Alters the type of the parameter from str to list
            or vice versa (or at least tries to). Basically this
            function tries to break things by playing with the types
            of the parameters.

            aiohttp parameters to php server variable examples:
                (param[],[1,2,3]) == $_[param] = [1,2,3]
                (param[],3) == $_[param] = [3]
                (param,[1,2,3]) == $_[param] = str(3)
                (param,3) == $_[param] = str(3)

                if types don't match take the last type
                [(param,3), (param,4)] == $_[param] = str(4)
                [(param,3), (param[],4)] == $_[param] = [4]
                [(param[],3), (param,4)] == $_[param] = str(4)

                [(param[3],13), (param[2],14)] == $_[param] = [2 => 14, 3 => 13]
        """
        logger = logging.getLogger(__name__)
        logger.debug("Mutate fun alter type")

        # if it is array access (has format param[.*])
        if len(re.findall(r"\[[^\[]*\]$", param)) > 0:
            # strip the last [.*] from it
            return re.sub(r"\[[^\[]*\]$", "", param), val
        else:
            # propably a normal string parameter
            return param + '[]', val

    @staticmethod
    def random_str(length: int) -> str:
        seq = random.choices([
                              string.ascii_lowercase,
                              string.ascii_uppercase, 
                              string.punctuation,
                              string.digits], weights=[10,10,50,30], k=1)[0]

        return ''.join(random.choices(seq, k=length))

    @staticmethod
    def add_random_text(param:str, 
                        val: List[str]) -> Tuple[str, List[str]]:
        """
            Prepend or append a random alphanumeric to
            the payload.
        """
        logger = logging.getLogger(__name__) # Gets the module's logger.
        logger.debug("Mutate fun add random text")

        payload:str = Mutator.random_str(random.randrange(1,2))

        if random.randint(HEADS,TAILS) == HEADS:
            return (param, list(map(lambda x: payload + x, val)))
        else:
            return (param, list(map(lambda x: x + payload, val)))
    
    def add_syntax_token(self, 
                         param:str, 
                         val: List[str]) -> Tuple[str, List[str]]:
        """
            Prepend and append a random HTML/JS/PHP syntax token to a parameter
        """
        logger = logging.getLogger(__name__)
        logger.debug("Mutate fun add syntax token")

        payload: str = self.syntax_tokens.payload

        if random.randint(HEADS,TAILS) == HEADS:
            return (param, list(map(lambda x: payload + x, val)))
        else:
            return (param, list(map(lambda x: x + payload, val)))

    def add_xss_payload(self, 
                        param: str, 
                        val: List[str]) -> Tuple[str, List[str]]:
        """
            Prepends or appends a random xss payload
            in the parameter.
        """
        logger = logging.getLogger(__name__)
        logger.debug("Mutate fun insert random xss")

        payload: str = self.xss_payloads.payload

        if random.randint(HEADS,TAILS) == HEADS:
            return (param, list(map(lambda x: payload + x, val)))
        else:
            return (param, list(map(lambda x: x + payload, val)))

    def add_strxss_payload(self,
                           param:str,
                           val: List[str]) -> Tuple[str, List[str]]:
        logger = logging.getLogger(__name__)
        logger.debug("Mutate fun insert random str+xss")

        (param2,val2) = self.add_xss_payload(param, val)

        return Mutator.add_random_text(param2, val2)
