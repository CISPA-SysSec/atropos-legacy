#!/usr/bin/python

import os, sys, argparse
import glob
from tqdm import tqdm
from icecream import ic

file_to_cmp = os.path.join("/dev/shm/rq/", f"{os.path.basename(sys.argv[1])}.cov")
if not os.path.isfile(file_to_cmp):
    print(f"{file_to_cmp} doesnt exist")
    sys.exit(-1)

m = {}
cov_files = [os.path.abspath(x) for x in glob.glob("/dev/shm/rq/*.cov")]

for cov_file in tqdm(cov_files):
    with open(cov_file, "r") as f:
        m[cov_file] = set([x.strip() for x in f.readlines()])

plot_lines = {}
file_times = {f: int(os.path.getctime(f)) for f in cov_files}
base_time = min(file_times.values())
file_times = {f: file_times[f] - base_time for f in file_times}
cumulative_data = set()
for cov_file in tqdm(sorted(cov_files, key=lambda x: file_times[x])):
    cumulative_data.update(m[cov_file])
    plot_lines[file_times[cov_file]] = cumulative_data

prev_time = max([x for x in file_times.values() if x < file_times[file_to_cmp]])
ic(prev_time)
ic(file_times[file_to_cmp])
whats_new = plot_lines[file_times[file_to_cmp]] - plot_lines[prev_time]
for w in sorted(whats_new):
    print(w)