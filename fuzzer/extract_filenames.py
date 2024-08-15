#!/usr/bin/python

import re
import glob
import sys
import os
import shutil
import argparse

parser = argparse.ArgumentParser(description="", prog="extract_filenames.py")
parser.add_argument('--src', '-n', dest='php_src', help='PHP source', nargs=1, required=True)
parser.add_argument('--dest', '-o', dest="dst_file", help="Destination file, where to output", nargs=1, required=True)
parser.add_argument('--exclude', '-e', dest="exclude", help="Exclude directories", nargs='*')
parser.add_argument('--add-parent-path', '-p', dest="parent_path", help="Change path from local-dir/bla to /vm/dir/bla", nargs=1)
args = parser.parse_args()

php_src = args.php_src[0]
dst_file = args.dst_file[0]
exclude = []
parent_path = "./"
if args.exclude:
    exclude = args.exclude
if args.parent_path:
    parent_path = args.parent_path[0]
    if not parent_path.endswith("/"):
        parent_path = f"{parent_path}/"

filenames = []
if os.path.isdir(php_src):
    filenames = glob.glob(f"{php_src}/**/*.php", recursive=True)
else:
    filenames = [php_src]

# exclude directories
for excluded_dir in exclude:
    excluded_dir = os.path.abspath(excluded_dir)
    print(excluded_dir)
    filenames = [f for f in filenames if not os.path.abspath(f).startswith(excluded_dir)]

print(filenames)
base_path = os.path.dirname(php_src)
if not base_path.endswith("/"):
    base_path += "/"
# adjust filenames to relative paths so they work in the VM too
filenames = [parent_path + f[f.index(base_path)+len(base_path):] for f in filenames]

print(filenames)
with open(dst_file, "w+") as f:
    f.write('\n'.join(filenames))