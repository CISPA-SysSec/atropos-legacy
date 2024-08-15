#!/usr/bin/python

from math import ceil
import os, sys, argparse, time, random

parser = argparse.ArgumentParser(description="", prog="parallel_fuzz.py")
parser.add_argument('num', nargs=1)
parser.add_argument('--input', '-f', dest='input', help='Directory with input files', nargs=1)
parser.add_argument('--debug', '-d', dest="debug", help="Activate debug mode: write out log file", action="store_true")
parser.add_argument('--power-cycle', dest="power_cycle", action="store_true")
parser.add_argument('--all-favored', dest="all_favored", action="store_true")
parser.add_argument('--disable-trimming', dest="disable_trimming", help="disables trimming on 50 percent of fuzzers, which is helpful when the trimming is too slow", action="store_true")
parser.add_argument('--start-file', dest="start_file", help="Start PHP file", nargs=1)
parser.add_argument('--disable-cov', dest="disable_cov", default=False, action="store_true")
parser.add_argument('--instances', dest="instances", help="How many instances of parallel fuzzers to start", type=int, nargs="?", default=1)
args = parser.parse_args()

# activate this if you want more fancy power schedules (recommended)
# power_schedules_core = ['explore', 'fast']
# power_schedules_other = ['coe', 'quad', 'lin', 'exploit', 'mmopt', 'rare', 'seek']
# power_schedules = power_schedules_core + power_schedules_other
power_schedules_core = ['explore']
power_schedules_other = ['explore']
power_schedules = power_schedules_core + power_schedules_other

if args.power_cycle:
    afl_cycle_schedules = "AFL_CYCLE_SCHEDULES=1"
else:
    afl_cycle_schedules = ""

print("\n")
num_parallel = int(args.num[0])
if args.disable_cov:
    num_fuzzer_parallel = num_parallel
else:
    num_fuzzer_parallel = ceil(num_parallel*0.9)
num_rest_parallel = num_parallel - num_fuzzer_parallel
input_dir = None
if args.input:
    input_dir = args.input[0]
WORKDIR  = os.getenv("WORKDIR")
SHAREDIR = os.getenv("SHAREDIR")
for instance in range(args.instances):
    for parallel_run in range(num_fuzzer_parallel):
        i = (instance*num_fuzzer_parallel)+parallel_run
        if num_fuzzer_parallel == 1:
            s = "-X"
        else:
            if parallel_run == 0:
                s = "-Y -M 0"
            else:
                s = "-Y -S %d" % parallel_run
        docker_name = "webapp_screen_%d" % i
        input_str = f"-i {WORKDIR}_in/"
        if args.instances == 1:
            output_dir = f"{WORKDIR}_out/"
        else:
            output_dir = f"{WORKDIR}_out_{instance}/"
        pinned_core = "PIN_CORE=%d" % i
        if input_dir is not None:
            input_str = f"-i {input_dir}"
        disable_trimming_str = ""
        if args.disable_trimming and i > 0 and random.random() < 0.5:
            disable_trimming_str = "AFL_DISABLE_TRIM=1"
        start_file = ""
        if args.start_file:
            start_file = f"START_FILE={args.start_file[0]}"
        afl_no_ui = "AFL_NO_UI=1" if args.debug else ""
        pipe = f"> /dev/shm/afl_log_{i}.txt 2>&1" if args.debug and num_parallel > 1 else ""
        all_favored = "AFL_ALL_FAVORED=1" if args.all_favored else ""
        if parallel_run == 0:
            if num_parallel == 1:
                power_scheduler = 'fast'
            else:
                power_scheduler = 'explore'
        else:
            # afl++ doc: 
            # "if you fuzz with several parallel afl-fuzz instances, 
            # then it is beneficial to assign a different schedule 
            # to each instance, however the majority should be fast 
            # and explore."
            if random.random() < 0.5:
                power_scheduler = random.choice(power_schedules_other)
            else:
                power_scheduler = random.choice(["explore", "fast"])
        power_scheduler_str = f"-p {power_scheduler}"
        # get the directory where this python script lies
        script_dir = os.path.dirname(os.path.realpath(__file__))
        php_fuzz = f"PYTHONPATH={script_dir} AFL_PYTHON_MODULE=php_input_mutator AFL_CUSTOM_MUTATOR_ONLY=1 PHP_DATA=/tmp/ BROWSER_DATA={script_dir}/browser_data.json {start_file} {pinned_core} {afl_cycle_schedules} {disable_trimming_str} {afl_no_ui} {all_favored} {script_dir}/AFLplusplus/afl-fuzz {input_str} -t 5000 -o {output_dir} {power_scheduler_str} {s} {SHAREDIR} {pipe}"
        if num_parallel == 1:
            e = php_fuzz
        else:
            e = f"screen -dmS {docker_name} bash -c '{php_fuzz}' > /dev/null 2>&1"
        print(e)
        os.system(e)
        time.sleep(1)
    
if not args.disable_cov and (num_parallel) > 1:
    # generate coverage plots
    print("starting cov generator")
    SINGLE_WORKDIR = f"{WORKDIR}_out/"
    e = f"screen -dmS webapp_cov bash -c 'PHP_DATA=/tmp/ BROWSER_DATA={script_dir}/browser_data.json SINGLE_ID=0 SINGLE_WORKDIR={SINGLE_WORKDIR} WORKDIR={WORKDIR} SHAREDIR={SHAREDIR} python3 {script_dir}/cov_generator.py {num_fuzzer_parallel}' > /dev/null 2>&1"
    print(e)
    os.system(e)
    time.sleep(1)

    # use 10% of the cores for other tasks, i.e., test all bug trigger on all inputs
    if num_rest_parallel > 1:
        for i in range(num_rest_parallel-1):
            print("starting crash triggerer")
            # try all bug triggers on all found inputs in the background for faster crash detection
            core = num_fuzzer_parallel+1+i
            e = f"screen -dmS webapp_crash_{core} bash -c 'PHP_DATA=/tmp/ BROWSER_DATA={script_dir}/browser_data.json WORKDIR={WORKDIR} SHAREDIR={SHAREDIR} python3 {script_dir}/crash_mutator.py {core}' > /dev/null 2>&1"
            print(e)
            os.system(e)
            time.sleep(1)
    
    print("\nall instances started!")
