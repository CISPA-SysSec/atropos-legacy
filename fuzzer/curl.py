#!/usr/bin/python

import sys, pickle
from icecream import ic
from misc import *

def inp_to_curl(inp):
    cookies = {string_urlencode(x): string_urlencode(y) for x,y in inp["COOKIE"].items()}
    post = {string_urlencode(x): string_urlencode(y) for x,y in inp["POST"].items()}
    get = {string_urlencode(x): string_urlencode(y) for x,y in inp["GET"].items()}
    query_string = '&'.join([f"{string_urlencode(name)}={string_urlencode(value)}" for (name, value) in inp["GET"].items()])
    script_filename = inp["meta"][s2h("filename")].decode()
    # some scripts need to know the relative path of the script (i.e. the script filename)
    script_name = script_filename.replace("/var/www/html/", "")
    h_request_uri = s2h("REQUEST_URI")
    if h_request_uri not in inp["SERVER"] or len(inp["SERVER"][h_request_uri]) == 0:
        if query_string == "":
            request_uri = f'/{script_name}'
        else:
            request_uri = f'/{script_name}?{query_string}'
    else:
        request_uri = inp["SERVER"][h_request_uri].decode("latin1")
    if request_uri.startswith("/"):
        request_uri = request_uri[1:]
    if len(post) > 0:
        method = "POST"
        curl_post = ' '.join([f"-d {x}={y}" for x,y in post.items()])
    else:
        method = "GET"
        curl_post = ''
    h_request_method = s2h("REQUEST_METHOD")
    if h_request_method in inp["SERVER"]:
        method = string_urlencode(inp["SERVER"][h_request_method])
    if len(cookies) > 0:
        curl_cookies = '-b "' + ' '.join([f"{x}={y};" for x,y in cookies.items()]) + '"'
    else:
        curl_cookies = ''
    return f"curl -X {method} {curl_post} {curl_cookies} http://localhost/{request_uri}"

pickle_file = sys.argv[1]
inp_list = pickle.load(open(pickle_file, "rb"))
ic(inp_list)

for inp in inp_list:
    print(inp_to_curl(inp))