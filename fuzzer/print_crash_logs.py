#!/usr/bin/python

import sys
import glob
import os
import time
import argparse
import re
import pickle
import codecs
from misc import *
from icecream import ic
from rapidfuzz.distance import Levenshtein

MAX_BUCKET_DISTANCE = 32

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

def extract_time(f):
    m = re.search('time:(\d*?),', f)
    if m:
        return int(m.group(1))
    else:
        return 0

def extract_id(f):
    m = re.search('id:(\d*?),', f)
    if m:
        return m.group(1)
    else:
        return 0

def crash_name(f):
    afl_id = extract_id(f)
    crash_dir = os.path.dirname(f)
    # sometimes the filename changes because the "time" part gets updated
    matching_crash_files = [f for f in glob.glob(f"{crash_dir}/id:{afl_id}*") if not f.endswith(".log")]
    assert(len(matching_crash_files) == 1)
    return matching_crash_files[0]

def crash_names(f):
    afl_id = extract_id(f)
    crash_dir = os.path.dirname(f)
    # sometimes the filename changes because the "time" part gets updated
    matching_crash_files = [f for f in glob.glob(f"{crash_dir}/id:{afl_id}*") if not f.endswith(".log")]
    return matching_crash_files

def find_bucket(m_reversed, error_msg):
    all_distances = {e: Levenshtein.distance(e, error_msg) for e in m_reversed}
    filtered_distances = {e: d for (e, d) in all_distances.items() if d < MAX_BUCKET_DISTANCE}
    if filtered_distances:
        return min(filtered_distances, key=lambda x: filtered_distances[x])
    else:
        return error_msg

def extract_filename_from_crash_log(crash_log):
    m = re.search('(/var/www.*?)(\s| |$|\))', crash_log)
    if m:
        return m.group(1)
    else:
        return crash_log

def read_crash_file(file):
    with open(file, "rb") as f:
        inp_list = pickle.load(f)
        return input_to_env(inp_list, file, {})["requests"]


parser = argparse.ArgumentParser(description="", prog="extract_filenames.py")
parser.add_argument('paths', nargs="+")
parser.add_argument('--watch', '-w', dest='watch', help='Only show dumps for this file', action="store_true")
parser.add_argument('--bucket', dest="bucket", help="Use levenshtein distance to bucket error messages", action="store_true")
parser.add_argument('--bucket-by-filename', dest="bucket_by_filename", help="Use filename in crash log to bucket", action="store_true")
parser.add_argument('--filter', dest="filter", help="Filter via python command (vars: error_msg)", nargs=1)
parser.add_argument('--print-input', '-p', dest="print_input", help="Print GET/POST etc. input (env variables)", action="store_true")
parser.add_argument('--verbose', '-v', dest="verbose", help="Print all filenames", action="store_true")
args = parser.parse_args()

while True:
    if args.watch:
        os.system("clear")
        os.system("date")
        print()

    m = {}
    m_reversed = {}
    min_time = {}
    bucket_to_msg = {}

    for path in args.paths:
        for file in glob.glob("%s/*.log" % path):
            with codecs.open(file, 'r', encoding='utf-8', errors='ignore') as f:
                error_msg = f.read()
                m[file] = error_msg
                if args.bucket:
                    bucket = find_bucket(m_reversed, error_msg)
                    bucket_to_msg[bucket] = bucket
                elif args.bucket_by_filename:
                    bucket = extract_filename_from_crash_log(error_msg)
                    bucket_to_msg[bucket] = error_msg
                else:
                    bucket = error_msg
                    bucket_to_msg[bucket] = bucket
                if bucket not in m_reversed:
                    m_reversed[bucket] = [file]
                    min_time[bucket] = extract_time(file)
                else:
                    m_reversed[bucket].append(file)
                    min_time[bucket] = min(extract_time(file), min_time[bucket])

    for error_msg in sorted(m_reversed, key=lambda x: min_time[x]):
        msg = bucket_to_msg[error_msg]
        files = [c for f in m_reversed[error_msg] for c in crash_names(f)]
        data = {f: read_crash_file(f) for f in files}
        data_envs = [f"{k}={v}" for f in data for e in data[f] for k,v in e.items()]
        show = (not args.filter) or (args.filter and eval(args.filter[0]))
        if show:
            if not args.verbose and len(files) > 10:
                print(files[:10], "... (cut, total: %d)" % len(files))
            else:
                print(files)
            if args.print_input:
                for f in files:
                    envs = read_crash_file(f)
                    for env in envs:
                        print(f)
                        print(bcolors.OKBLUE + ' '.join([f"{k}={v}" for k,v in env.items()]) + bcolors.ENDC)
            print(bcolors.FAIL + msg + bcolors.ENDC)
            print()
    
    if not args.watch:
        break
    time.sleep(60)