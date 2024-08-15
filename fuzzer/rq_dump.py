#!/usr/bin/python

from icecream import ic
from misc import *
import os
import sys
import glob

def encode_non_printable(s):
    r = ""
    printables = set(string.ascii_letters + string.digits + string.punctuation + ' _-')
    for c in s:
        if c in printables:
            r += c
        else:
            r += "\\x%02x" % ord(c)
    return r

_paths = sys.argv[1:]
rq_files = []
for _path in _paths:
    if os.path.isdir(_path):
        rq_files.extend([os.path.join(_path, x) for x in glob.glob(f"{_path}/*.rq")])
    else:
        rq_files.append(_path)

data = []
for f in rq_files:
    ic(f)
    r = parse_redqueen_file(f)
    #ic(r)
    for k in r:
        for d in r[k]:
            if isinstance(d, tuple) or isinstance(d, list):
                d = list(d)
            else:
                d = [d]
            decoded = []
            for b in d:
                try:
                    b = encode_non_printable(b.decode())
                except:
                    ic("skipping", b)
                    continue
                decoded.append(b)
            decoded = ' -> '.join(decoded)
            data.append(f"{k}::{decoded}")
    
for d in sorted(list(set(data))):
    print(d)