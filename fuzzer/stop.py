#!/usr/bin/python3

import os, multiprocessing, shutil, glob, sys, re, subprocess
from pathlib import Path
from icecream import ic

def get_shell(cmd):
  process = subprocess.Popen(cmd, shell=True,
                             stdout=subprocess.PIPE, 
                             stderr=subprocess.PIPE)
  # wait for the process to terminate
  out, err = process.communicate()
  errcode = process.returncode
  return out

num_screens = int(get_shell("docker ps | wc -l"))
for i in range(num_screens):
    os.system(f"screen -S webapp_screen_{i} -X stuff $'\\003' > /dev/null 2>&1")
    os.system(f"screen -X -S webapp_screen_{i} quit > /dev/null 2>&1")
os.system("pkill -9 -f qemu")
os.system("pkill -f afl-fuzz")
os.system("screen -wipe")
print("stop done")
