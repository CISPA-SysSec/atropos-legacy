import psutil
import subprocess
import curses
import asyncio
import os
import time
from os import system
# from wFuzz.curses_ui import FuzzersInterface

menu = ["Automated Fuzzing", "Manual Fuzzing", "Exit"]

class Curses_menu:

    def __init__(self):
        pass
    async def automated_fuzzing(self, stdscr):
        start = time.time()
        # Clear window
        stdscr.clear()
        # Now getch will be non-blocking
        stdscr.nodelay(1)

        # curses.echo()

        title = "Web Fuzzer (v1.0)"
        h, w = stdscr.getmaxyx()
        x_title = w // 2 - len(title) // 2
        y_title = 0

        # Title
        stdscr.attron(curses.color_pair(4))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_title, x_title, title)

        stdscr.attroff(curses.color_pair(4))
        stdscr.attroff(curses.A_BOLD)

        # Status Bar
        statusbarstr = "Press 'q' to exit | Press 'm' to enter manual mode | Progress 0 %"
        stdscr.attron(curses.color_pair(3))
        stdscr.addstr(h - 1, 0, statusbarstr)
        stdscr.addstr(h - 1, len(statusbarstr), " " * (w - len(statusbarstr) - 1))
        stdscr.attroff(curses.color_pair(3))

        # Process Timing
        y_title += 2
        stdscr.attron(curses.color_pair(2))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_title, 0, "Process Stats")

        stdscr.attroff(curses.color_pair(2))
        stdscr.attroff(curses.A_BOLD)

        y_pid = y_title + 1
        stdscr.addstr(y_pid, 2, "pid: ")

        y_run = y_pid + 1
        stdscr.addstr(y_run, 2, "run time: ")

        y_cpu = y_run + 1
        stdscr.addstr(y_cpu, 2, "cpu usage: ")

        y_cpufreq = y_cpu + 1
        stdscr.addstr(y_cpufreq, 2, "cpu frequency: ")

        y_ram = y_cpufreq + 1
        stdscr.addstr(y_ram, 2, "memory usage: ")

        # y_net = y_ram + 1
        # stdscr.addstr(y_net, 2, "network latency: ")
        y_through = y_ram + 1
        stdscr.addstr(y_through, 2, "throughput:")

        # Overall Progress

        stdscr.attron(curses.color_pair(2))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_title, w // 2, "Overall Progress")

        stdscr.attroff(curses.color_pair(2))
        stdscr.attroff(curses.A_BOLD)

        y_payloads = y_title + 1
        stdscr.addstr(y_payloads, w // 2 + 2, f"{'requests sent:':20s}")

        y_code_coverage = y_payloads + 1
        stdscr.addstr(y_code_coverage, w // 2 + 2, f"{'current coverage:':20s}")

        y_tot_code_coverage = y_code_coverage + 1
        stdscr.addstr(y_tot_code_coverage, w // 2 + 2, f"{'global coverage:':20s}")

        y_new_links = y_tot_code_coverage + 1
        stdscr.addstr(y_new_links, w // 2 + 2, f"{'unseen links:':20s}")

        # y_through = y_new_links + 1
        # stdscr.addstr(y_through, w // 2 + 2, f"{'throughput:':20s}")

        #y_overhead = y_new_links + 1
        #stdscr.addstr(y_overhead, w // 2 + 2, f"{'wFuzz overhead:':20s}")

        y_rxss = y_new_links + 1
        stdscr.addstr(y_rxss, w // 2 + 2, f"{'possible rxss:':20s}")

        # Node Details

        stdscr.attron(curses.color_pair(2))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_through + 1, 0, "Node Details")

        stdscr.attroff(curses.color_pair(2))
        stdscr.attroff(curses.A_BOLD)
        
        y_link = y_through + 2
        stdscr.addstr(y_link, 2, "executing link: ")
        
        y_state = y_link + 1
        stdscr.addstr(y_state, 2, "state: ")

        # Border lines
        stdscr.attron(curses.color_pair(5))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(2, len("Process Stats"), "-" * (w // 2 - len("Process Stats")))  # First box

        stdscr.addstr(2, len("Overall Progress") + w // 2, "-" * (w // 2 - len("Overall Progress") + 1))  # Second Box

        stdscr.addstr(y_through + 1, len("Node Details"), "-" * (w - len("Node Details")))

        stdscr.addstr(y_through * 2, 0, "-" * w)

        stdscr.attroff(curses.color_pair(5))
        stdscr.attroff(curses.A_BOLD)

        stdscr.attron(curses.color_pair(5))
        stdscr.attron(curses.A_BOLD)

        for i in range(y_through - 2):
            # First row of boxes
            stdscr.addstr(i + 3, 0, "|")
            stdscr.addstr(i + 3, w - 1, "|")
            stdscr.addstr(i + 3, w // 2, "|")

            # Second row of boxes
            stdscr.addstr(i + y_through + 2, 0, "|")
            stdscr.addstr(i + y_through + 2, w - 1, "|")
            stdscr.addstr(i + y_through + 2, w // 2, "|")

        stdscr.attroff(curses.color_pair(5))
        stdscr.attroff(curses.A_BOLD)

        # Pid of process running the fuzzer
        stdscr.addstr(y_pid, len("  pid: "), str(os.getpid()))  # Only need to be calculated once.

        counter = 0
        payloads = 0
        key = 0

        prev_count = 0
        through = 0
        prev_tm = time.clock_gettime(time.CLOCK_MONOTONIC)

        # self._stdout, self._stderr = f.communicate()

        while key != ord('q'):
            await asyncio.sleep(0.2)

            # Run time calculation
            end = time.time()
            elapsed_time = int(end - start)
            stdscr.addstr(y_run, len("  run time: "), '{:02d} hrs, {:02d} min, {:02d} sec'.format(elapsed_time // 3600, (elapsed_time % 3600 // 60), elapsed_time % 60))

            statistics = {}

            # Get Physical and Logical CPU Count
            physical_and_logical_cpu_count = os.cpu_count()
            statistics['physical_and_logical_cpu_count'] = physical_and_logical_cpu_count
            cpu_load = [x / os.cpu_count() * 100 for x in os.getloadavg()][-1]
            statistics['cpu_load'] = cpu_load
            stdscr.addstr(y_cpu, len("  cpu usage: "), f"{statistics['cpu_load']:.2f} % (" + str(physical_and_logical_cpu_count) + " cores)")

            # CPU frequencies
            cpufreq = psutil.cpu_freq()
            stdscr.addstr(y_cpufreq, len("  cpu frequency: "), f"{cpufreq.current / 1000:.2f} GHz")

            # Memory usage
            stdscr.addstr(y_ram, len("  memory usage: "), str(psutil.virtual_memory().percent) + " %")

            # Throughput
            cur_tm = time.clock_gettime(time.CLOCK_MONOTONIC)
            if cur_tm - prev_tm > 2:
                through = (self.fuzzer.stats["req_count"] - prev_count) / (cur_tm - prev_tm)
                prev_count = self.fuzzer.stats["req_count"]
                prev_tm = cur_tm

            stdscr.addstr(y_through, len("  throughput: "), f"{through:8.3f} req/sec")

            #ping_result = subprocess.run(['ping', '-c 2', 'google.com'], stdout=subprocess.PIPE).stdout.decode('utf-8').split('\n')
            
            #min, avg, max = ping_result[-2].split('=')[-1].split('/')[:3]
            #statistics['network_latency'] = avg.strip()
            # statistics['network_latency'] = 0
            #
            # stdscr.addstr(y_net, len("  network latency: "), str(statistics['network_latency']) + " ms")

            # Overall Progress Box Calculations
            stdscr.addstr(y_payloads, w // 2 + len("  requests sent: "), f"{self.fuzzer.stats['req_count']:10d}")

            cfg_score_tot = 100*len(self.fuzzer._node_list._total_cfg_single)/self.fuzzer._const["label-count"]

            if self.fuzzer._cur_node is not None:
                cfg_score = 100*self.fuzzer._cur_node.get_cover_score()/self.fuzzer._const["combinations"]
            else:
                cfg_score = 0

            stdscr.addstr(y_code_coverage, w // 2 + len("  current coverage: "), f"{ cfg_score :10.3f} %")
            stdscr.addstr(y_tot_code_coverage, w // 2 + len("  global coverage: "), f"{ cfg_score_tot :10.3f} %")

            stdscr.addstr(y_new_links, w // 2 + len("  unseen links: "), f"{ self.fuzzer.stats['new_link_count'] :10d}")
         
            #if self.fuzzer._cur_node is not None and self.fuzzer.stats["req_time_tot"] != 0:
                #overhead = 100*(self.fuzzer.stats["req_time_tot"] - self.fuzzer._cur_node.exec_time)/self.fuzzer.stats["req_time_tot"]
            #else:
                #overhead = 0
                
            #if overhead < 0: overhead = 0

            #stdscr.addstr(y_overhead, w // 2 + len("  wFuzz overhead: "), f"{self.fuzzer._cur_node.get_exec_time():10.3f} %")

            stdscr.addstr(y_rxss, w // 2 + len("  possible rxss: "), f"{self.fuzzer._parser.get_xss_count():10d}")

            # Fuzzing Node Details Box Calculations
            
            if self.fuzzer._cur_node is not None:
                stdscr.addstr(y_link, len("  executing link:  "), self.fuzzer._cur_node.get_url()[:105]+" "*(39-len(self.fuzzer._cur_node.get_url()[:105])))
                
                if self.fuzzer._cur_node.get_cover_score_parent() == 0:
                    stdscr.addstr(y_state, len("  state:  "), "Crawling")
                else:
                    stdscr.addstr(y_state, len("  state:  "), "Fuzzing ")

            # Get input
            key = stdscr.getch()
            if key == ord('q'):
                stdscr.nodelay(0)
                code = self.print_exit(stdscr)
                if code > 0:
                    return code
                # In case of no it will return back so the interface must be printed again
                self.automated_fuzzing_helper(stdscr)
                stdscr.nodelay(1)

            key = 0
            stdscr.refresh()


    
    async def run(self, fuzzer_object):
        self.fuzzer = fuzzer_object
        await curses.wrapper(self.draw_menu)

    async def draw_menu(self, stdscr):
        # turn off cursor blinking
        curses.curs_set(0)

        # Start colors in curses
        curses.start_color()
        curses.init_pair(1, curses.COLOR_RED, curses.COLOR_BLACK)  # title colour
        curses.init_pair(2, curses.COLOR_YELLOW, curses.COLOR_BLACK)  # line colour
        curses.init_pair(3, curses.COLOR_BLACK, curses.COLOR_WHITE)  # color scheme for selected row
        curses.init_pair(4, curses.COLOR_CYAN, curses.COLOR_BLACK)  # automated fuzzing title colour
        curses.init_pair(5, curses.COLOR_MAGENTA, curses.COLOR_BLACK)  # automated fuzzing title colour

        # Initialize key to zero
        key = 0

        # Specify the current selected row
        current_row = 0

        # Print the menu
        self.print_menu(stdscr, current_row)

        # Loop where k is the last character pressed
        while key != ord('q'):

            # Get input
            key = stdscr.getch()

            if key == curses.KEY_UP and current_row > 0:
                current_row -= 1
            elif key == curses.KEY_DOWN and current_row < len(menu) - 1:
                current_row += 1
            elif key == curses.KEY_ENTER or key in [10, 13]:
                if current_row == 0:
                    loop_task = asyncio.create_task(self.fuzzer.fuzzer_loop())
                    stats_task = asyncio.create_task(self.automated_fuzzing(stdscr))
                    # stats_task.set_name("print_stats")
                    # loop_task.set_name("fuzzer_loop")

                    r = await stats_task
                    system("reset")
                    return r

                if current_row == 1:
                    self.print_center(stdscr, "You selected '{}'".format(menu[current_row]))
                    stdscr.getch()
                # if user selected last row, check if he really wants to exit the program
                if current_row == len(menu) - 1:
                    self.print_exit(stdscr)

            self.print_menu(stdscr, current_row)


    def print_exit(self, stdscr):
        stdscr.clear()

        h, w = stdscr.getmaxyx()

        current_row = 0

        while 1:
            stdscr.clear()

            self.print_center(stdscr, "Are you sure you want to exit?")

            x_opt = int(w // 2 - 2)
            y_opt = int(h // 2) + 1
            if current_row == 0:
                stdscr.attron(curses.color_pair(3))
                stdscr.addstr(y_opt, x_opt, "Yes")
                stdscr.attroff(curses.color_pair(3))
            else:
                stdscr.addstr(y_opt, x_opt, "Yes")

            if current_row == 1:
                stdscr.attron(curses.color_pair(3))
                stdscr.addstr(y_opt, x_opt + 4, "No")
                stdscr.attroff(curses.color_pair(3))
            else:
                stdscr.addstr(y_opt, x_opt + 4, "No")

            # Get input
            key = stdscr.getch()

            if key == curses.KEY_LEFT and current_row == 1:
                current_row = 0
            elif key == curses.KEY_RIGHT and current_row == 0:
                current_row = 1
            elif key == curses.KEY_ENTER or key in [10, 13]:
                if current_row:
                    return 0
                else:
                    # self._f.terminate()
                    return 1

            stdscr.refresh()

    def print_menu(self, stdscr, selected_row_idx):
        # Clear window
        stdscr.clear()

        # Get height and width of current terminal window
        height, width = stdscr.getmaxyx()

        # Declaration of title strings
        title1 = "                  ______                      "
        title2 = "       _      __ / ____/__  __ ____ ____      "
        title3 = "      | | /| / // /_   / / / //_  //_  /      "
        title4 = "      | |/ |/ // __/  / /_/ /  / /_ / /_      "
        title5 = "      |__/|__//_/     \__,_/  /___//___/      "
        title6 = "      ----------------------------------      "

        # Centering calculations
        start_x_title1 = int((width // 2) - (len(title1) // 2) - len(title1) % 2)
        start_x_title2 = int((width // 2) - (len(title2) // 2) - len(title2) % 2)
        start_x_title3 = int((width // 2) - (len(title3) // 2) - len(title3) % 2)
        start_x_title4 = int((width // 2) - (len(title4) // 2) - len(title4) % 2)
        start_x_title5 = int((width // 2) - (len(title5) // 2) - len(title5) % 2)
        start_x_title6 = int((width // 2) - (len(title6) // 2) - len(title6) % 2)

        start_y = int((height // 5) - 2)

        # Turning on attributes for title
        stdscr.attron(curses.color_pair(1))
        stdscr.attron(curses.A_BOLD)

        # Rendering title
        stdscr.addstr(start_y, start_x_title1, title1)
        stdscr.addstr(start_y + 1, start_x_title2, title2)
        stdscr.addstr(start_y + 2, start_x_title3, title3)
        stdscr.addstr(start_y + 3, start_x_title4, title4)
        stdscr.addstr(start_y + 4, start_x_title5, title5)

        # Turning off attributes for title
        stdscr.attroff(curses.color_pair(1))
        stdscr.attroff(curses.A_BOLD)

        stdscr.attron(curses.color_pair(2))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(start_y + 6, start_x_title6, title6)

        stdscr.attroff(curses.color_pair(2))
        stdscr.attroff(curses.A_BOLD)

        for idx, row in enumerate(menu):
            x = int(width // 2 - len(row) // 2)
            y = int(start_y + 8 + idx)
            if idx == selected_row_idx:
                stdscr.attron(curses.color_pair(3))
                stdscr.addstr(y, x, row)
                stdscr.attroff(curses.color_pair(3))
            else:
                stdscr.addstr(y, x, row)
        stdscr.refresh()

    def print_center(self, stdscr, text):
        stdscr.clear()
        h, w = stdscr.getmaxyx()
        x = w // 2 - len(text) // 2
        y = h // 2
        stdscr.addstr(y, x, text)
        stdscr.refresh()

    def automated_fuzzing_helper(self, stdscr):
        stdscr.clear()
        title = "Web Fuzzer (v1.0.0)"
        h, w = stdscr.getmaxyx()
        x_title = w // 2 - len(title) // 2
        y_title = 0

        # Title
        stdscr.attron(curses.color_pair(4))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_title, x_title, title)

        stdscr.attroff(curses.color_pair(4))
        stdscr.attroff(curses.A_BOLD)

        # Status Bar
        statusbarstr = "Press 'q' to exit | Press 'm' to enter manual mode | Progress 0 %"
        stdscr.attron(curses.color_pair(3))
        stdscr.addstr(h - 1, 0, statusbarstr)
        stdscr.addstr(h - 1, len(statusbarstr), " " * (w - len(statusbarstr) - 1))
        stdscr.attroff(curses.color_pair(3))

        # Process Stats
        y_title += 2
        stdscr.attron(curses.color_pair(2))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_title, 0, "Process Stats")

        stdscr.attroff(curses.color_pair(2))
        stdscr.attroff(curses.A_BOLD)

        y_pid = y_title + 1
        stdscr.addstr(y_pid, 2, "pid: ")

        y_run = y_pid + 1
        stdscr.addstr(y_run, 2, "run time: ")

        y_cpu = y_run + 1
        stdscr.addstr(y_cpu, 2, "cpu usage: ")

        y_cpufreq = y_cpu + 1
        stdscr.addstr(y_cpufreq, 2, "cpu frequency: ")

        y_ram = y_cpufreq + 1
        stdscr.addstr(y_ram, 2, "memory usage: ")

        y_net = y_ram + 1
        stdscr.addstr(y_net, 2, "network latency: ")

        # Overall Progress

        stdscr.attron(curses.color_pair(2))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_title, w // 2, "Overall Progress")

        stdscr.attroff(curses.color_pair(2))
        stdscr.attroff(curses.A_BOLD)

        y_crashes = y_title + 1
        stdscr.addstr(y_crashes, w // 2 + 2, "unique crashes: ")

        y_payloads = y_crashes + 1
        stdscr.addstr(y_payloads, w // 2 + 2, "payloads tested: ")

        y_code_coverage = y_payloads + 1
        stdscr.addstr(y_code_coverage, w // 2 + 2, "code coverage: ")

        # Overall Progress

        stdscr.attron(curses.color_pair(2))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(y_net + 1, 0, "Fuzzing Strategies")

        stdscr.attroff(curses.color_pair(2))
        stdscr.attroff(curses.A_BOLD)

        # Border lines
        stdscr.attron(curses.color_pair(5))
        stdscr.attron(curses.A_BOLD)

        stdscr.addstr(2, len("Process Stats"), "-" * (w // 2 - len("Process Stats")))  # First box

        stdscr.addstr(2, len("Overall Progress") + w // 2, "-" * (w // 2 - len("Overall Progress") + 1))  # Second Box

        stdscr.addstr(y_net + 1, len("Fuzzing Strategies"), "-" * (w - len("Fuzzing Strategies")))

        stdscr.addstr(y_net * 2, 0, "-" * w)

        stdscr.attroff(curses.color_pair(5))
        stdscr.attroff(curses.A_BOLD)

        stdscr.attron(curses.color_pair(5))
        stdscr.attron(curses.A_BOLD)

        for i in range(y_net - 2):
            # First row of boxes
            stdscr.addstr(i + 3, 0, "|")
            stdscr.addstr(i + 3, w - 1, "|")
            stdscr.addstr(i + 3, w // 2, "|")

            # Second row of boxes
            stdscr.addstr(i + y_net + 2, 0, "|")
            stdscr.addstr(i + y_net + 2, w - 1, "|")
            stdscr.addstr(i + y_net + 2, w // 2, "|")

        stdscr.attroff(curses.color_pair(5))
        stdscr.attroff(curses.A_BOLD)

        # Pid of process running the fuzzer
        stdscr.addstr(y_pid, len("  pid: "), str(os.getpid()))  # Only need to be calculated once.
