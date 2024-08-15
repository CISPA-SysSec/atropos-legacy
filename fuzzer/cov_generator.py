#!/usr/bin/python

import php_input_mutator
import ctypes
import pickle
import os
import signal
import numpy as np
import glob
import json
import time
import random
import sys
from libnyx import *
from icecream import ic
from hashable_bytearray import *

CPU_CORE = int(sys.argv[1]) if len(sys.argv) > 1 else 72

def cstr(s):
    return ctypes.create_string_buffer(s.encode("ascii"))

def bytearray_to_nyx_input(b):
    ptr_c_ubyte = ctypes.POINTER(ctypes.c_ubyte)
    return ptr_c_ubyte((ctypes.c_ubyte * len(b)).from_buffer_copy(b))

php_input_mutator.init("")
default_input = bytearray(pickle.dumps([php_input_mutator.default_input]))

work_dir = f"{os.getenv('WORKDIR')}_out/workdir/"
ptr = nyx_new_child(cstr("webapp_share"), cstr(work_dir), CPU_CORE, CPU_CORE)
nyx_option_set_reload_mode(ptr, 1)
nyx_option_set_timeout(ptr, 150, 0)
_inp = php_input_mutator.post_process(bytearray())
nyx_set_afl_input(ptr, bytearray_to_nyx_input(_inp), len(_inp))
nyx_option_apply(ptr)

if os.path.isdir(f"{os.getenv('WORKDIR')}_out/default/"):
  main_workdir_path = f"{os.getenv('WORKDIR')}_out/default"
elif os.path.isdir(f"{os.getenv('WORKDIR')}_out/0/"):
  main_workdir_path = f"{os.getenv('WORKDIR')}_out/0/"

while True:
  queue_files = glob.glob(f"{main_workdir_path}/queue/id*")
  random.shuffle(queue_files)
  for q in queue_files:
    seed_filename = os.path.basename(q)
    cov_dst_filename = os.path.join("/dev/shm/rq/", f"{seed_filename}.cov")
    if os.path.isfile(cov_dst_filename):
      continue

    try:
      ic(q)
    except:
      pass

    with open(q, "rb") as f:
      inp = f.read()
    _envs = php_input_mutator.post_process(inp, exec_limit=0)
    envs = json.loads(_envs[:-1].decode("ascii"))
    envs["config"]["COVERAGE_DUMP"] = str(CPU_CORE)
    has_install = False
    for r in envs["requests"]:
      if "install" in r["SCRIPT_FILENAME"] or "setup" in r["SCRIPT_FILENAME"]:
        has_install = True
        break
    if has_install:
      continue
    _envs = HashableBytearray(json.dumps(envs).encode("ascii")) + HashableBytearray([0x00])
    envs_inp = bytearray_to_nyx_input(_envs)
    nyx_set_afl_input(ptr, envs_inp, len(_envs))
    nyx_exec(ptr)
    cov_dump_file = os.path.join(work_dir, f"dump/coverage_{CPU_CORE}")
    if os.path.isfile(cov_dump_file):
      # trim it down => remove duplicate entries
      # it's not a full chronological trace anymore, but that's enough for coverage measurement
      trimmed_cov = php_input_mutator.trim_coverage_file(cov_dump_file)
      with open(cov_dst_filename, "w+") as f:
          f.write(trimmed_cov)
      os.remove(cov_dump_file)
  print("All files processed, sleeping 30s....")
  time.sleep(30)
nyx_shutdown(ptr)