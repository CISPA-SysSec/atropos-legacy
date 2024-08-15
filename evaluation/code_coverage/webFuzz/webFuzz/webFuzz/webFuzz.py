#!/usr/bin/env python3.9

"""
CLI-Runner for webFuzz
"""

from webFuzz.fuzzer import Fuzzer
from webFuzz.types  import Arguments

args = Arguments().parse_args()

fuzzer = Fuzzer(args)
fuzzer.run()
