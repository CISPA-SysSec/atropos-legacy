#!/usr/bin/python

import sys
import pprint
import pickle
import os
import glob
import argparse
import re
from icecream import ic
import string
import urllib.parse
import json
from misc import *
import shlex

default_host = "localhost:8000"
default_host_url = f"http://{default_host}/"
default_filename: str = "/var/www/html/index.php"
default_server_variables = {}

# $_SERVER variables that can not be mutated by the client
server_vars_blacklist = set([
    'PHP_SELF',
    'argv',
    'argc',
    'GATEWAY_INTERFACE',
    'SERVER_ADDR',
    'SERVER_NAME',
    'SERVER_SOFTWARE',
    'SERVER_PROTOCOL',
    'REQUEST_TIME',
    'REQUEST_TIME_FLOAT',
    'QUERY_STRING',
    'DOCUMENT_ROOT',
    'REMOTE_ADDR',
    'REMOTE_HOST',
    'REMOTE_PORT',
    'REMOTE_USER',
    'REDIRECT_REMOTE_USER',
    'SCRIPT_FILENAME',
    'SERVER_ADMIN',
    'SERVER_PORT',
    'SERVER_SIGNATURE',
    'PATH_TRANSLATED',
    'SCRIPT_NAME',
    'REQUEST_URI',
    'PATH_INFO',
    'ORIG_PATH_INFO',
    "REDIRECT_STATUS",
    "CONTENT_LENGTH",
    "POST_DATA",
    "HTTP_COOKIE",
    "SERVER_NAME",
])

def unpickle(path):
	with open(path, "rb") as f:
		try:
			data = pickle.load(f)
		except:
			sys.stderr.write("Can't unpickle %s\n" % path)
			return None
		return data

# def bytearray_to_urlencode(bytes: bytearray) -> str:
#     s = ""
#     for b in bytes:
#         s += f"%{b:02x}"
#     return s

# def bytearray_to_urlencode(bytes: bytearray) -> str:
#     s = ""
#     printable = string.ascii_letters + string.digits # + ['_']
#     for b in bytes:
#         c = chr(b)
#         if c in printable:
#             s += c
#         else:
#             s += f"%{b:02x}"
#     return s

def env_quote(env):
	return shlex.quote(env).replace('\n', '')

def print_pickle(path, data):
	global default_server_variables
	if data is not None:
		print(f"\n\n########### {path} ########### ")
		pp.pprint(data)

		envs = input_to_env(data, default_filename, default_server_variables)["requests"]
		for env_vars in envs:
			env_vars["LD_LIBRARY_PATH"] = "/tmp/"
			env_vars["LD_BIND_NOW"] = "1"

			print('')
			print("URL: ", env_vars["REQUEST_URI"] if env_vars["REQUEST_URI"] != "" else "/%s?%s" % (env_vars["SCRIPT_NAME"], env_vars["QUERY_STRING"]))
			print("POST DATA: ", env_vars["POST_DATA"])
			print('')
			quoted_envs = ' '.join('%s=%s' % (k, env_quote(v)) for k,v in env_vars.items() if not k.startswith("_RAW"))
			print(f'{quoted_envs} /tmp/php-cgi -c /tmp/php.ini')
		#ic(data)

def print_pickle_if_not_filtered(path, file_filter, concat=None):
	l = unpickle(path)
	print_this = None
	if l is not None and file_filter:
		filter_passed = False
		for data in l:
			(_, value) = data['meta'][0]
			value = value.decode()
			if value.endswith(file_filter):
				filter_passed = True
				break
		if filter_passed:
			print_this = (path, l)
	else:
		print_this = (path, l)
	if print_this is not None:
		if l is not None and concat != -1:
			if len(l) == concat:
				(path, data) = print_this
				print_pickle(path, data)
		else:
			(path, data) = print_this
			print_pickle(path, data)

def extract_time(f):
    m = re.search('time:(\d*?),', f)
    if m:
        return int(m.group(1))
    else:
        return os.path.getmtime(f)

pp = pprint.PrettyPrinter(indent=4, compact=True)

parser = argparse.ArgumentParser(description="", prog="extract_filenames.py")
parser.add_argument('paths', nargs="+")
parser.add_argument('--filter', '-f', dest='file_filter', help='Only show dumps for this file', nargs=1)
parser.add_argument('--concat', '-c', dest="concat", help="Only show concat files (second order vulnerabilities)", nargs='?', default="-1")
parser.add_argument('--id-sort', '-i', dest="id_sort", help="Sort by queue ID instead of file change time", action="store_true")
parser.add_argument('--browser', '-b', dest="browser", nargs=1)
parser.add_argument('--allow-sync', dest="allow_sync", help="Also dump sync files", action="store_true")
parser.add_argument('--last', dest="last", help="Print only the last n entries", nargs=1)
args = parser.parse_args()

paths = args.paths
file_filter = None
id_sort = False
last = None
if args.file_filter:
	file_filter = args.file_filter[0]
if args.concat:
	concat_limit = int(args.concat)
if args.id_sort:
	id_sort = True
if args.browser:
	browser_data_file = args.browser[0]
	with open(browser_data_file, "r") as f:
		browser_data_export = json.loads(f.read())
		default_server_variables = browser_data_export["SERVER"] #{key: string_urlencode(value) for (key, value) in browser_data_export["SERVER"].items()}
if args.last:
	last = int(args.last[0])

files = []
for path in paths:
	if "*" in path or os.path.isdir(path):
		files.extend([os.path.join(path, f) for f in glob.glob(f"{path}/**", recursive=True) if os.path.isfile(f)])
	if os.path.isfile(path):
		files.append(path)

if len(files) > 1 and not args.allow_sync:
	files = [f for f in files if "sync:" not in f]

if id_sort:
	sorted_files = sorted(files)
else:
	sorted_files = sorted(files, key = lambda x: extract_time(x))
if last is not None:
	sorted_files = sorted_files[-last:]
for f in sorted_files:
	if os.path.isfile(f):
		print_pickle_if_not_filtered(f, file_filter, concat=concat_limit)
	else:
		print_pickle_if_not_filtered(f, file_filter, concat=concat_limit)
