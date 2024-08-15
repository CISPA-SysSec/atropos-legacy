import logging

import asyncio
import aiohttp

from typing           import Callable, Iterator, Any, Dict, List, Tuple
from difflib          import SequenceMatcher
from urllib.parse     import parse_qs
from math             import log2, ceil
from aiohttp.client   import ClientSession, TraceConfig
from aiohttp.typedefs import CIMultiDictProxy
from os               import path, access, R_OK
from functools        import partial

from .types           import get_logger, ExitCode, Numeric, Label, Bucket
from .environment     import env

def object_to_tuple(d: object) -> tuple:
    if isinstance(d, str) or isinstance(d, int) or isinstance(d, float):
        return tuple(str(d))

    if isinstance(d, list):
        d.sort()
        return tuple([object_to_tuple(x) for x in d])
    
    if isinstance(d, dict):
        keys = list(d.keys())

        keys.sort()
        return tuple([(k, object_to_tuple(d[k])) for k in keys])
    
    return tuple('')

def retrieve_headers() -> Dict[str,str]:
    return {
        'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36',
        'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8,el;q=0.7',
        'accept': 'text/html,application/xhtml+xml',
        "Cache-Control": "no-cache",
        "Pragma": "no-cache"
    }

def query_to_dict(query: str) -> Dict[str, List[str]]:
    # Parse a query string as a dict.
    return parse_qs(query, keep_blank_values=True)


def iter_join(primary: Iterator,
              secondary: Iterator, 
              periodic: Iterator,
              interval: int = 10) -> Iterator:
    count = 0

    while True:
        if count == 0:
            try:
                yield (periodic, next(periodic))
            except StopIteration:
                pass

        try:
            yield (primary, next(primary))
        except StopIteration:
            try:
                yield (secondary, next(secondary))
            except StopIteration:
                return
        
        count += 1
        if count % interval == 0:
            count = 0

def sigint_handler(*args: Any, **kwargs: Any) -> None:
    logger = get_logger(__name__)
    logger.info('SIGINT received')
    print("\nFuzzer PAUSED")
    while True:
        try:
            response = input('\nAre you sure you want to exit? Type (yes/no):\n')
            if response == "yes":
                env.shutdown_signal = ExitCode.USER
                return
            if response == "debug":
                root = get_logger()
                root.setLevel(logging.DEBUG)
                return
            if response == "info":
                root = get_logger()
                root.setLevel(logging.INFO)
                return
            else:
                return
        except KeyboardInterrupt:
            pass

def sigalarm_handler(*args: Any, **kwargs: Any) -> None:
    logger = get_logger(__name__)
    logger.warning('Reached timeout, stopping fuzzing process')
    env.shutdown_signal = ExitCode.TIMEOUT

def longest_str_match(haystack: str, needle: str) -> int:
    match = SequenceMatcher(None, haystack, needle)
    (_,__,size) = match.find_longest_match(0, len(haystack), 0, len(needle))
    
    return size


def calc_weighted_difference(value1: Numeric, value2: Numeric, weight: float) -> float:
    """
    Calculate the weighted difference between two numeric values
    Formula: (weight * (value2 - value1)) / (|value1 + value2| / 2)
    """
    their_sum = abs(value1 + value2) / 2
    return weight * (value1 - value2)/their_sum if their_sum > 0 else 0

def to_bucket(hit_count: int) -> Bucket:
    # 9 buckets: 1  2  3-4  5-8  9-16 17-32 33-64 65-128 129-255
    return ceil(log2(hit_count)) if hit_count < 256 else 8

def parse_headers(raw_headers: CIMultiDictProxy[str]) -> Iterator[Tuple[Label, str]]:
    relevant_headers = filter(lambda h: h[0].startswith("I-"), raw_headers.items())
    for name, value in relevant_headers:
        yield (int(name[2:]), value)

def parse_file(filename: str) -> Iterator[Tuple[Label, str]]:
    if not path.isfile(filename) or not access(filename, R_OK):
        return

    with open(filename, "r") as f:
        for line in f.readlines():
            if not line: continue
            line = line.replace("\n", "")

            label, _, value = line.partition('-')
            yield (int(label), value)

def lazyFunc(f: Callable, *args) -> Iterator:
    r = partial(f, *args)()
    while True:
        yield r

def rtt_trace_config() -> TraceConfig:
    async def on_request_start(session: ClientSession,
                               trace_config_ctx,
                               params: aiohttp.TraceRequestStartParams) -> None:
                        
        trace_config_ctx.start = asyncio.get_event_loop().time()

    async def on_request_end(session: ClientSession,
                             trace_config_ctx,
                             params: aiohttp.TraceRequestEndParams) -> None:
                             
        elapsed_time = asyncio.get_event_loop().time() - trace_config_ctx.start
        trace_config_ctx.trace_request_ctx.exec_time = elapsed_time

    exec_time_config = TraceConfig()
    exec_time_config.on_request_start.append(on_request_start)
    exec_time_config.on_request_end.append(on_request_end)

    return exec_time_config

