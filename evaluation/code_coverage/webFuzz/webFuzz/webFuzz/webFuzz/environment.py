"""
   This module stores a global variable 'env' that stores environment data
   such as cli-arguments and instrumentation arguments.
   This variable is initialised once during the first module import.
   and should only that be imported by other modules. The Fuzzer class
   will set env.args and env.instrument_args during the initialisation phase.
"""


from .types import Arguments, ExitCode, InstrumentArgs
from typing import Optional


class Environment:
    args: Optional[Arguments] = None
    instrument_args: Optional[InstrumentArgs] = None
    shutdown_signal: ExitCode = ExitCode.NONE

env = Environment()
