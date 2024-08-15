#!/usr/bin/env python3.8
""" Black-box version of webFuzz. *NOT COMPLETED*

This module provides a black-box functionality for fuzzing a
web application. The source code of this module is heavily commented
in order to provide a detailed documentation for the reader. The code
is written python3.8.
"""
import logging
import signal
import time
import aiohttp
import asyncio
import os
import curses
import random

from os import symlink, unlink, mkdir
from datetime import datetime

# user modules
from .node import Node
from .node_list import Node_list
from .parser import Parser
from .simple_menu import Simple_menu
from .curses_menu import Curses_menu
from .environment import env


class CustomFormatter(logging.Formatter):
    """Logging Formatter to add colors and count warning / errors"""

    grey = "\x1b[38;11m"
    cyan = "\x1b[96;11m"
    yellow = "\x1b[33;11m"
    red = "\x1b[31;21m"
    bold_red = "\x1b[31;21m"
    reset = "\x1b[0m"
    dformat = "[%(asctime)s] %(name)s %(levelname)s %(funcName)s(%(lineno)d) %(message)s"
    level_col = {
        logging.DEBUG: grey,
        logging.INFO: cyan,
        logging.WARNING: yellow,
        logging.ERROR: red,
        logging.CRITICAL: bold_red
    }

    def format(self, record):

        if record.funcName == "run_worker":
            (logname, work_id) = record.name.split('/')
            record.name = logname
            wformat = f"[%(asctime)s] %(name)s %(levelname)s [Worker {work_id}] %(funcName)s(%(lineno)d) %(message)s"
            log_fmt = self.level_col.get(record.levelno) + wformat + self.reset
        else:
            log_fmt = self.level_col.get(record.levelno) + self.dformat + self.reset

        formatter = logging.Formatter(log_fmt)
        return formatter.format(record)


class Fuzzer:
    def __init__(self):
        args = env.args

        try:
            mkdir("./log")
        except FileExistsError:
            pass

        # Creation of the current run's log file name
        dt = datetime.now()
        log_file = f"./log/webFuzz_manual_{dt.day}-{dt.month}_{dt.hour}:{dt.minute}.log"
        file_handler = logging.FileHandler(log_file)  # Configure the root logger to write to a file.

        try:
            unlink("fuzzer_blackbox.log")
        except FileNotFoundError:
            pass
        # Creation of a symlink to the latest fuzzer log for ease of access
        symlink(log_file, "./fuzzer_blackbox.log")

        # Format of each line in the log file using custom formatter
        file_handler.setFormatter(CustomFormatter())
        file_handler.setLevel(logging.DEBUG)

        # Initialise root logger and let descendant module loggers
        # propagate their logs to root module handlers.
        # note: descendant loggers will inherit root's log level
        # see: https://docs.python.org/3/_images/logging_flow.png
        root_logger = logging.getLogger()
        root_logger.addHandler(file_handler)

        # Log level definition from argument (-v).
        # If the log level of a log is lower than logger level specified here, the log will be ignored.
        if args.verbose == 0:
            root_logger.setLevel(logging.ERROR)
        elif args.verbose == 1:
            root_logger.setLevel(logging.WARNING)
        elif args.verbose == 2:
            root_logger.setLevel(logging.INFO)
        else:
            root_logger.setLevel(logging.DEBUG)

        logger = logging.getLogger(__name__)
        logger.debug(args)

        self.timeout = args.timeout

        self.worker_count = args.worker

        # Statistics for the current fuzzing session that will be printed
        self.stats = {"map_density_current": 0,
                      "map_density_total": 0,
                      "cur_cover_score": 0,
                      "new_link_count": 0,
                      "req_count": 0,
                      "response_time_net": 0.0,
                      "response_time_tot": 0.0,
                      "response_time_la": 0.0,
                      "xss_count": 0}

        cookies = {}
        if args.session:
            # since the chromedriver is not universal and depends on the chrome's version,
            # the user needs his own matching chromedriver else it results in errors. As a fix
            # we defer loading .browser module unless the flag is passed
            from .browser import get_cookies
            if not os.path.isabs(args.driver):
                args.driver = os.path.dirname(__file__) + '/../' + args.driver

            cookies = {c['name']: c['value'] for c in get_cookies(args.driver, args.URL)}

            logger.info("got cookies: %s", cookies)

        headers = {
            'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36',
            'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8,el;q=0.7',
            'accept': 'text/html,application/xhtml+xml'}

        self._session_data = {"cookies": cookies, "headers": headers}

        # Create a new node list
        self._node_list = Node_list(blocklist=args.block, crawler_unseen=set([Node(url=args.URL, method="GET", cover_score_parent=0, params={}, xss_params=set())]))

        self._parser = Parser(args.URL, self._node_list._mutator.xss_payloads)

        # points to the current executing node
        self._cur_node = None

    async def run_worker(self, work_id):
        logger = logging.getLogger(__name__ + "/" + work_id)
        logger.info("Worker reporting Active")

        while True:
            prev_tm = time.clock_gettime(time.CLOCK_MONOTONIC)

            new_req = self._node_list.get_next()
            if new_req is None:
                logger.error("Aborting due to lack of paths")
                self._cur_node = None
                return 4

            self.stats["req_count"] += 1  # Increment request made counter

            try:
                logger.info("sending request: %s", new_req)
                exit_early = False

                self._session_data["headers"].update({"REQ-ID": work_id})  # Add id to request.

                if new_req.method == "GET":  # Here is where the request to the target is made
                    r = await self._session.get(new_req.url, headers=self._session_data["headers"],
                                                params=new_req.params, trace_request_ctx=new_req)
                else:  # Only data differs from a GET request
                    r = await self._session.post(new_req.url, headers=self._session_data["headers"],
                                                 data=new_req.params, trace_request_ctx=new_req)

                if r.content_type != 'text/html':
                    logger.info('Got non html payload: %s', r.content_type)
                    exit_early = True

                if r.status != 200:
                    logger.warning('Got code %d from %s', r.status, r.url)
                    # enable this if you want the html in the logs too
                    # logger.debug("Dumping html %s: ", await r.text())
                    exit_early = True

                if exit_early:
                    r.close()  # Close request.
                    self.stats["req_time_tot"] = time.clock_gettime(time.CLOCK_MONOTONIC) - prev_tm
                    continue

            except Exception as e:
                logger.error(e, exc_info=True)

            else:
                # enable this if you want the html in the logs too
                # logger.debug("Raw html: " + await r.text())
                self._cur_node = new_req  # Print stats of running node.

                try:
                    links = await self._parser.parse(r, new_req)  # Parsing the response of new request
                except Exception as e:
                    logger.error(e, exc_info=True)
                    continue

                # new_req.parse_instrumentation(r.headers, self._const, work_id=work_id)

                self._node_list.add(new_req)  # Insert node into heap

                self.stats.update(self._node_list.add_new_links(links))  # Update stats for new links found.

                r.close()  # Close connection

                self.stats["req_time_tot"] = time.clock_gettime(time.CLOCK_MONOTONIC) - prev_tm  # Save time needed for request and processing.

    """
        The method that will execute the actual fuzzer. The fuzzer is run in an infinite loop.
        The user can terminate its execution whenever he wishes.
    """

    async def fuzzer_loop(self):
        logger = logging.getLogger(__name__)

        async def on_request_start(session, trace_config_ctx, params):
            trace_config_ctx.start = asyncio.get_event_loop().time()

        async def on_request_end(session, trace_config_ctx, params):
            elapsed = asyncio.get_event_loop().time() - trace_config_ctx.start
            trace_config_ctx.trace_request_ctx.exec_time = elapsed

        exec_time_config = aiohttp.TraceConfig()
        exec_time_config.on_request_start.append(on_request_start)
        exec_time_config.on_request_end.append(on_request_end)

        self._session = aiohttp.ClientSession(cookies=self._session_data["cookies"],
                                              headers=self._session_data["headers"], trace_configs=[exec_time_config])
        signal.alarm(self.timeout)

        logger.info("Spawning %d workers", self.worker_count)

        self.workers = []

        for i in range(self.worker_count):
            work_id = str(random.randrange(0, 1000000))
            self.workers.append(asyncio.create_task(self.run_worker(work_id)))

            # randomize their start times using random offset
            offset = float(random.randrange(10, 20)) / 10

            if i == 0:
                # if it is the first worker spawned
                # also wait until at least one request/response cycle is done
                # this is needed because workers that find an empty queue exit
                offset *= 5

            await asyncio.sleep(offset)

        for w in self.workers:
            await w

    """
        Starting point for the Fuzzer execution with simple print interface. Here you can specify
        async tasks to run *concurrently* and register async safe Signal Handlers
    """

    async def run_simple(self, tofile):
        loop = asyncio.get_running_loop()
        obj = self

        # these need to be defined inline (i.e. closures) so
        # that we can use the object instance
        def sigint():
            logger = logging.getLogger(__name__)
            logger.info('SIGINT received')
            print("\nFuzzer PAUSED")

            while True:
                try:
                    response = input('\nAre you sure you want to exit? Type (yes/no):\n')
                    if response == "yes":
                        asyncio.create_task(obj._grace_exit(2))
                        return
                    if response == "debug":
                        root = logging.getLogger()
                        root.setLevel(logging.DEBUG)
                        return
                    if response == "info":
                        root = logging.getLogger()
                        root.setLevel(logging.INFO)
                        return
                    else:
                        return
                except KeyboardInterrupt:
                    pass

        def timeout(signum, frame):
            logger = logging.getLogger(__name__)
            logger.info('Reached timeout, stopping fuzzing process')
            asyncio.create_task(obj._grace_exit(3))

        loop.add_signal_handler(signal.SIGINT, sigint)
        loop.add_signal_handler(signal.SIGALRM, timeout)

        if tofile:
            f = open("/tmp/fuzzer_stats", "w+")

            def printer(line):
                f.write(line + "\n")

            def refresh():
                f.truncate(0)
                f.seek(0)

            sm = Simple_menu(obj, printer, refresh, f.flush)
        else:
            sm = Simple_menu(obj)

        asyncio.create_task(sm.print_stats(), name="print_stats")

        loop_task = asyncio.create_task(self.fuzzer_loop(), name="fuzzer_loop")

        r = await loop_task
        await self._grace_exit(r)

    async def _grace_exit(self, exit_code=0):
        logger = logging.getLogger(__name__)

        logger.warning('Shutting Down Fuzzer..')
        print("Exiting..")

        await self._session.close()

        logging.shutdown()

        for task in asyncio.Task.all_tasks():
            if task.get_name() in ["print_stats", "fuzzer_loop"]:
                task.cancel()
            else:
                task.cancel()

    """
        Starting point for the Fuzzer execution with curses interface. Here you can specify
        async tasks to run *concurrently* and register async safe Signal Handlers
    """

    async def run_curses(self):
        loop = asyncio.get_running_loop()
        obj = self

        # these need to be defined inline (i.e. closures) so
        # that we can use the object instance
        def sigint():
            logger = logging.getLogger(__name__)
            logger.info('SIGINT received')
            print("\nFuzzer PAUSED")

            while True:
                try:
                    response = input('\nAre you sure you want to exit? Type (yes/no):\n')
                    if response == "yes":
                        asyncio.create_task(obj._grace_exit(2))
                        return
                    else:
                        return
                except KeyboardInterrupt:
                    pass

        def timeout(signum, frame):
            logger = logging.getLogger(__name__)
            logger.info('Reached timeout, stopping fuzzing process')
            asyncio.create_task(obj._grace_exit(3))

        loop.add_signal_handler(signal.SIGINT, sigint)
        loop.add_signal_handler(signal.SIGALRM, timeout)

        obj = self
        cm = Curses_menu(obj)
        interface = asyncio.create_task(curses.wrapper(cm.draw_menu))
        exit_code = await interface

        await self._grace_exit(exit_code)
