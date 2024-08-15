"""
    A Node_list is responsible for inserting new nodes, bookkeeping for the visited links (for the crawler),
    and retrieving the most favorable node.

    A node should be retrieved and added here
    only through its methods (get_next_request(), add) in order to preserve the ordering
"""

import heapq

from typing         import Dict, List, Set, Optional
import random

from .node          import Node
from .types         import CFGTuple, HTTPMethod, List, Label, CFG, Policy, get_logger
from .environment   import env

class NodeIterator:
    """
        Constructs a heap tree of nodes plus a bunch of other data structures
        The heap tree (self._node_list) is semi-ordered in descending order of 
        favorableness. self._node_list[0] is the currently most favorable node

        :param crawler_unseen: links that have never been called yet
        :type crawler_unseen: Set of Nodes
        :return: The NodeList object
        :rtype: NodeList
    """
    def __init__(self):
        self.node_list: List[Node] = []
        self._total_cfg_xor: Dict[Label, List[Optional[Node]]] = {}
        self._total_cfg_single: Dict[Label, List[Optional[Node]]] = {}

    @property
    def total_cover_score(self):
        if env.instrument_args.policy == Policy.EDGE:
            total_cfg = self._total_cfg_xor
            total_count = env.instrument_args.edges
        else:
            total_cfg = self._total_cfg_single
            total_count = env.instrument_args.basic_blocks

        return 100*len(total_cfg) / total_count

    def _remove_nodes(self, tobe_removed: Set[Node]):
        logger = get_logger(__name__)

        if len(tobe_removed) == 0:
            return

        # BUG: sometimes the amount of nodes removed are less
        # than len(pending_removal). this should not happen
        # making self._node_list a set reduces its length (why !?)
        prev_len = len(self.node_list)

        self.node_list = list(set(self.node_list) - tobe_removed)

        logger.info("New node replaced %d/%d nodes", \
                    prev_len - len(self.node_list), len(tobe_removed))
        
        heapq.heapify(self.node_list)
    
    """
        Add node to the total cfg map

        A new node is accepted only if any of the conditions hold:
            1) has visited a label-bucket that we have not seen before
            2) it visited a label-bucket in which we have seen the past,
               but the node that visited that label is heavier than this
               new node (in terms of response time and size, see Node.isLighterThan)
        
        :param new_node: the node to add
        :type new_node: Node
        :param local_cfg: the xor-CFG of the node
        :type local_cfg: CFG
    """
    def _add_node_to_total_cfg(self, new_node: Node, local_cfg: CFG) -> None:
        # similar to AFL, the global map (self._total_cfg) 
        # stores for each bucket in each label we have seen
        # the lightest node that can reach it
        
        # strictly all nodes in the heap tree (self._node_list) exist
        # also in the global map. If a node loses its references
        # in the global map, then it gets removed from the heap too.

        if env.instrument_args.policy == Policy.NODE:
            total_cfg = self._total_cfg_single
        else:
            total_cfg = self._total_cfg_xor

        tobe_removed = set()
        for label, bucket in local_cfg.items():

            if label not in total_cfg:
                nodes: List[Optional[Node]] = [None,None,None,None,None,None,None,None,None]
                nodes[bucket] = new_node
                total_cfg[label] = nodes
                new_node.ref_count += 1
                continue

            existing_node = total_cfg[label][bucket]

            if existing_node is None:
                total_cfg[label][bucket] = new_node
                new_node.ref_count += 1

            elif new_node.is_lighter_than(existing_node):
                existing_node.ref_count -= 1
                if existing_node.ref_count == 0:
                    tobe_removed.add(existing_node)

                new_node.ref_count += 1
                total_cfg[label][bucket] = new_node

        self._remove_nodes(tobe_removed)

    """
        Add new node to the heap tree and to the global CFG map.

        :param new_node: the node to add
        :type new_node: Node
        :param node_cfg: the CFGs observed for this node
        :type node_cfg: CFGTuple
        :return: if the node has been accepted
        :rtype: bool
    """
    def add(self, new_node: Node, node_cfg: CFGTuple):
        logger = get_logger(__name__)

        if env.instrument_args.policy == Policy.NODE_EDGE:
            for label in node_cfg.single_cfg.keys():
                self._total_cfg_single[label] = []
        
        if env.instrument_args.policy == Policy.NODE:
            self._add_node_to_total_cfg(new_node, node_cfg.single_cfg)
        else:
            self._add_node_to_total_cfg(new_node, node_cfg.xor_cfg)

        if new_node.ref_count == 0:
            logger.info("New node not favorable, not adding it")
            return False
        else:
            # add the node to the heaptree
            heapq.heappush(self.node_list, new_node)

            logger.info("New list length: %d", len(self.node_list))
            logger.debug("List dump %s", self.node_list)
            return True

    def __iter__(self):
        return self

    """
        Get the next node to send a request to.
        New unseen requests have the highest priority. 
        Otherwise we pick the most favorable already 
        visited node, mutate it and return the result

        :return: the next request to sent
        :rtype: Node
    """
    def __next__(self):
        logger = get_logger(__name__)

        if len(self.node_list) == 0:
            logger.error("No more links to follow found.")
            raise StopIteration
        
        node = heapq.heappop(self.node_list)
        
        node.picked_score += 1

        heapq.heappush(self.node_list, node)

        return node
