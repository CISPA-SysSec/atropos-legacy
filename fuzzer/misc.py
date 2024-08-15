#!/usr/bin/python

import string, urllib
import rstr
import stopit
import struct
import os
import json
from typing import *
from icecream import ic

from hashable_bytearray import HashableBytearray

MAX_STATIC_STRING_LENGTH = 64 # when statically extracting strings, ignore strings longer than this
REDQUEEN_STRING     = 0x00
REDQUEEN_ARRAY_KEY  = 0x01
REDQUEEN_UNMATCHED  = 0x02
REDQUEEN_PREG_MATCH = 0x03

def generate_filepaths(filepath):
    generated = set()
    for back_dots in range(5): # the maximum backwards depth (how many "../")
        for extension in ["", ".php", ".php\x00"]: # sometimes no extension is allowed
            for forward_slash in ["", "/"]: # some paths needs to start with a slash
                for backward_slashes in ["../", "..././"]: # common method for stopping LFI is deleting "../", which can be circumvented
                    s = forward_slash + (backward_slashes*back_dots) + filepath + extension
                    generated.add(s) 
    return generated

bug_trigger_magic: Dict[str, List[str]] = {
    "sql": [
        # sql injection and remote code execution
        "' crash ", 
        '" crash ', 
        "\\ crash ",
        "` crash "],
    "rce": [
        # remote command execution (/tmp/crash is an actual binary that reports a crash via NYX)
        " /tmp/crash; ", 
        "; /tmp/crash; ", 
        '"; /tmp/crash; ',
        "'; /tmp/crash; ",
        " $(/tmp/crash) ",
        " $(`/tmp/crash`) ",
        " `/tmp/crash` ",
        "` `/tmp/crash` ",
        ";\n/tmp/crash; ",
        "\n /tmp/crash ",
        "crash'\"!§$%&/()=?`*+#^-.,;:"],
    "lfi_quick": [
        # lfi
        "/var/www/html/crash",
        "/var/www/html/crash.php",
        "/var/www/html/crash.php\x00",
        ""],
    "lfi": [],
    "eval": [
        # php code execution
        "<?php exec('/tmp/crash'); ?>",
        '<?php exec("/tmp/crash"); ?>',
        '<?php include("/var/www/html/crash.php"); ?>',
        "<?php include('/var/www/html/crash.php'); ?>",
        "exec('/tmp/crash');",
        "exec('/tmp/crash')",
        "'.exec('/tmp/crash').'",
        '".exec("/tmp/crash")."',
        "exec(chr(0x2f).chr(0x74).chr(0x6d).chr(0x70).chr(0x2f).chr(0x63).chr(0x72).chr(0x61).chr(0x73).chr(0x68));"],
    "upload": [
        "secret_write_trigger",
        "GIF89a<?php include('/var/www/html/crash.php'); ?>" # smallest gif file containing PHP code, actually works for getimagesize!
    ],
    "misc": ["crash"]
}

# build lfi strings with different ../ depths and variations
generated_lfi = generate_filepaths("crash")

bug_trigger_magic["lfi"].extend(list(generated_lfi))

# upload oracle strings (filepaths and partial paths, without extension etc.)
if os.path.isfile("/tmp/extract.json"):
    with open("/tmp/extract.json", "rb") as f:
        j = json.load(f)
    upload_paths = set()
    for f in j["filename_strings"]:
        upload_paths.update(generate_filepaths(f))
    bug_trigger_magic["upload"].extend(list(upload_paths))

# encode all bug oracles
for bug in bug_trigger_magic:
    for i,entry in enumerate(bug_trigger_magic[bug]):
        bug_trigger_magic[bug][i] = entry.encode()

# $_SERVER variables that can not be mutated by the client
server_vars_blacklist = set([
    'PHP_SELF',
    'argv',
    'argc',
    'PATH',
    'GATEWAY_INTERFACE',
    'SERVER_ADDR',
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
    'SERVER_SIGNATURE',
    'PATH_TRANSLATED',
    'SCRIPT_NAME',
    'PATH_INFO',
    'ORIG_PATH_INFO',
    "REDIRECT_STATUS",
    "CONTENT_LENGTH",
    "POST_DATA",
    "HTTP_COOKIE",
    "REDQUEEN",
    "COVERAGE"
])


server_vars_whitelist = set([
    'REQUEST_METHOD',
    'AUTH_TYPE',
    'PHP_AUTH_DIGEST',
    'PHP_AUTH_USER',
    'PHP_AUTH_PW',
    'PATH_INFO',
    'ORIG_PATH_INFO',
    'REQUEST_URI',
    'PATH_TRANSLATED',
    'SERVER_NAME', # in some cases this is set to user-supplied data
    'SERVER_PORT',
    "CONTENT_TYPE",
    "CONTENT_DISPOSITION",
    "UPLOAD_KEY",
    "UPLOAD_FILENAME",
    "UPLOAD_CONTENT_TYPE",
    "UPLOAD_CONTENT"
])

server_keep_after_trimming = set([
    "CONTENT_TYPE",
    "CONTENT_DISPOSITION",
    "UPLOAD_FILENAME",
    "UPLOAD_CONTENT_TYPE",
    "UPLOAD_CONTENT"
])

def is_upload_mode(inp):
    return (s2h("UPLOAD_KEY") in inp["SERVER"])

def s2h(h: str) -> HashableBytearray:
    return HashableBytearray(h.encode())

def bytearray_to_urlencode(bytes: HashableBytearray) -> str:
    s = ""
    for b in bytes:
        s += f"%{b:02x}"
    return s

def env_encode(bytes: HashableBytearray) -> str:
    s = ""
    printable = string.ascii_letters + string.digits 
    for b in bytes:
        c = chr(b)
        if c in printable:
            s += c
        else:
            s += f"%{b:02x}"
    return s

def env_str(b: HashableBytearray) -> str:
    return b.decode("latin-1") 

def string_urlencode(s: str) -> str:
	return urllib.parse.quote(s)

def input_to_env(inp_list, default_filename, default_server_variables):
    envs = {"config": {}, "requests": []}
    for inp in inp_list:
        # set environment variables to PHP-CGI
        env_vars = {}
        env_vars.update({key: str(value) for (key,value) in default_server_variables.items()})
        env_vars.update({
                    "REDIRECT_STATUS": "1",
                    "QUERY_STRING": "",
                    "SCRIPT_FILENAME": default_filename,
                    "CONTENT_LENGTH": "0",
                    "POST_DATA": "",
                    "HTTP_COOKIE": "",
                    "DOCUMENT_ROOT": "/var/www/html"
                    })

        upload_mode = is_upload_mode(inp)
        env_vars["QUERY_STRING"] = '&'.join([f"{string_urlencode(name)}={string_urlencode(value)}" for (name, value) in inp["GET"].items()])
        env_vars["_RAW_GET"] = {string_urlencode(x): string_urlencode(y) for (x,y) in inp["GET"].items()}
        if upload_mode:
            # special post format is required in upload mode
            post_data = ""
            # add all post inputs
            for (name, value) in inp["POST"].items():
                post_data += f'-----------------------------196539603416852482923876057105\nContent-Disposition: form-data; name="{string_urlencode(name)}"\n\n{env_str(value)}\n'
            # add upload file
            CONTENT_DISPOSITION = string_urlencode(inp["SERVER"].get(s2h("CONTENT_DISPOSITION"), s2h("form-data")))
            UPLOAD_KEY = string_urlencode(inp["SERVER"].get(s2h("UPLOAD_KEY"), HashableBytearray()))
            UPLOAD_FILENAME = string_urlencode(inp["SERVER"].get(s2h("UPLOAD_FILENAME"), HashableBytearray()))
            UPLOAD_CONTENT_TYPE = string_urlencode(inp["SERVER"].get(s2h("UPLOAD_CONTENT_TYPE"), s2h("text/plain")))
            UPLOAD_CONTENT = env_str(inp["SERVER"].get(s2h("UPLOAD_CONTENT"), HashableBytearray()))

            post_data += f'-----------------------------196539603416852482923876057105\nContent-Disposition: {CONTENT_DISPOSITION}; name="{UPLOAD_KEY}"; filename="{UPLOAD_FILENAME}"\nContent-Type: {UPLOAD_CONTENT_TYPE}\n\n{UPLOAD_CONTENT}\n'
            post_data += '-----------------------------196539603416852482923876057105--'
            env_vars["POST_DATA"] = post_data
        else:
            env_vars["POST_DATA"] = '&'.join([f"{string_urlencode(name)}={string_urlencode(value)}" for (name, value) in inp["POST"].items()])
        env_vars["_RAW_POST"] = {string_urlencode(x): string_urlencode(y) for (x,y) in inp["POST"].items()}
        env_vars["CONTENT_LENGTH"] = str(len(str(env_vars["POST_DATA"])))
        env_vars["HTTP_COOKIE"] = '; '.join([f"{string_urlencode(name)}={string_urlencode(value)}" for (name, value) in inp["COOKIE"].items()]) 
        env_vars["_RAW_COOKIE"] = {string_urlencode(x): string_urlencode(y) for (x,y) in inp["COOKIE"].items()}

        env_vars["SCRIPT_FILENAME"] = inp["meta"][s2h("filename")].decode()
        # some scripts need to know the relative path of the script (i.e. the script filename)
        env_vars["SCRIPT_NAME"] = env_vars["SCRIPT_FILENAME"].replace("/var/www/html", "")
        env_vars["PHP_SELF"] = env_vars["SCRIPT_NAME"]
        h_request_uri = s2h("REQUEST_URI")
        if h_request_uri not in inp["SERVER"] or len(inp["SERVER"][h_request_uri]) == 0:
            if env_vars["QUERY_STRING"] == "":
                env_vars["REQUEST_URI"] = f'/{env_vars["SCRIPT_NAME"]}'
            else:
                env_vars["REQUEST_URI"] = f'/{env_vars["SCRIPT_NAME"]}?{env_vars["QUERY_STRING"]}'
        else:
            env_vars["REQUEST_URI"] = env_str(inp["SERVER"][h_request_uri])
        
        set_if_not_set = {
            "HTTP_USER_AGENT": "Mozilla/5.0 (X11; Linux aarch64; rv:78.0) Gecko/20100101 Firefox/78.0",
            "CONTENT_TYPE": "application/x-www-form-urlencoded",
        }
        for e in set_if_not_set:
            if e not in env_vars:
                env_vars[e] = set_if_not_set[e]

        for (name, value) in inp["SERVER"].items():
            try:
                name_str = name.decode()
            except:
                continue
            # name must be printable and also not blacklisted from being overwritten
            if not name_str.isprintable() or (name_str not in server_vars_whitelist and not name_str.startswith("HTTP_")): #or name_str in server_vars_blacklist:
                continue
            env_vars[name_str] = env_str(value)

        if "REQUEST_METHOD" not in env_vars:
            env_vars["REQUEST_METHOD"] = "GET"
        if env_vars["REQUEST_METHOD"] == "GET" and len(str(env_vars["POST_DATA"])) > 0:
            env_vars["REQUEST_METHOD"] = "POST"

        envs["requests"].append(env_vars)
    return envs

class ReadBeyondEnd(Exception):
    pass

def read_bytes(f, len, filesize):
    if f.tell()+len > filesize:
        ic(f.tell(), len, filesize)
        raise ReadBeyondEnd()
    else:
        return f.read(len)

def parse_redqueen_file(rq_file):
    preg_match_cache = {}
    strings = []
    key_strings = []
    unmatched_strings = []
    preg_matches = []
    with open(rq_file, "rb") as f:
        f.seek(0, 2)
        file_size = f.tell()
        f.seek(0, 0)
        try:
            while f.tell() < file_size:
                s_type = struct.unpack('B', read_bytes(f, 1, file_size))[0]
                if s_type in [REDQUEEN_STRING, REDQUEEN_ARRAY_KEY]:
                    length = struct.unpack('h', read_bytes(f, 2, file_size))[0]
                    if length > 0:
                        content = HashableBytearray(struct.unpack(f'={length}s', read_bytes(f, length, file_size))[0])
                    else:
                        content = HashableBytearray()
                    strings.append(content)
                    if s_type == REDQUEEN_ARRAY_KEY:
                        key_strings.append(content)
                elif s_type in [REDQUEEN_UNMATCHED, REDQUEEN_PREG_MATCH]:
                    len1 = struct.unpack('h', read_bytes(f, 2, file_size))[0]
                    if len1 > 0:
                        str1 = HashableBytearray(struct.unpack(f'={len1}s', read_bytes(f, len1, file_size))[0])
                    else:
                        str1 = HashableBytearray()
                    len2 = struct.unpack('h', read_bytes(f, 2, file_size))[0]
                    if len2 > 0:
                        str2 = HashableBytearray(struct.unpack(f'={len2}s', read_bytes(f, len2, file_size))[0])
                    else:
                        str2 = HashableBytearray()
                    strings.extend([str1, str2])
                    if s_type == REDQUEEN_UNMATCHED:
                        unmatched_strings.append((str1, str2))
                    elif s_type == REDQUEEN_PREG_MATCH:
                        regexp = str1
                        cmp_str = str2
                        if regexp in preg_match_cache:
                            preg_matches.extend(preg_match_cache[regexp])
                            strings.extend(preg_match_cache[regexp])
                        else:
                            try:
                                regexp_str = regexp.decode("latin1")
                                clean = clean_regexp(regexp_str)
                                shortest_rev = HashableBytearray(shortest_reverse_regexp(clean, timeout=5))
                                additional_revs = [HashableBytearray(x) for x in reverse_regexp_count(clean, 3, timeout=5)]
                            except:
                                continue
                            preg_matches.append(shortest_rev)
                            preg_matches.extend(additional_revs)
                            strings.append(shortest_rev)
                            strings.extend(additional_revs)
                            preg_match_cache[regexp] = additional_revs + [shortest_rev]
                        # if we know which part of a string was unmatched, specifically replace those parts
                        for r in preg_match_cache[regexp]:
                            unmatched_strings.append((cmp_str, r))
                assert(s_type in [0x00, 0x01, 0x02, 0x03])
        except ReadBeyondEnd as e:
            pass
    return {"strings": strings, "key_strings": key_strings, "unmatched_strings": unmatched_strings, "preg_matches": preg_matches}

@stopit.threading_timeoutable(default=[])
def reverse_regexp_count(regexp, count):
    reversed = []
    tries = 0
    while len(reversed) < count and tries < 50:
        tries += 1
        try:
            s = rstr.xeger(regexp).encode()
        except:
            continue
        if len(s) < MAX_STATIC_STRING_LENGTH:
            reversed.append(s)
    return reversed

@stopit.threading_timeoutable(default='')
def shortest_reverse_regexp(regexp):
    shortest = None
    for _ in range(50):
        try:
            s = rstr.xeger(regexp).encode()
        except:
            continue
        if shortest is None or len(s) < len(shortest):
            shortest = s
    return shortest

def remove_delimiter(rev):
    if len(rev) == 0:
        return rev
    # php.net: "A delimiter can be any non-alphanumeric, non-backslash, non-whitespace character."
    delimiters = set(string.printable) - set(string.ascii_letters) - set(string.digits) - set(string.whitespace) 
    # php.net: "Leading whitespace before a valid delimiter is silently ignored. "
    rev_stripped = rev.lstrip()
    if rev[0] in delimiters:
        choice = rev
        delimiter = rev[0]
    elif len(rev_stripped) > 0 and rev_stripped[0] in delimiters:
        choice = rev_stripped
        delimiter = rev_stripped[0]
    else:
        return rev
    # php.net: "It is also possible to use bracket style delimiters where the opening and closing brackets are the starting and ending delimiter, respectively. (), {}, [] and <> are all valid bracket style delimiter pairs."
    if delimiter in '({[<':
        m = {'(': ')', 
             '{': '}', 
             '[': ']', 
             '<': '>'}
        closing_delimiter = m[delimiter]
    else:
        closing_delimiter = delimiter
    if closing_delimiter not in choice[1:]:
        return choice
    last_delimiter_pos = choice.rindex(closing_delimiter)
    pattern_modifiers = choice[last_delimiter_pos+1:]
    pattern_modifiers_valid = all((c in 'imsxADSUXJu' for c in pattern_modifiers))
    if pattern_modifiers_valid:
        return choice[1:last_delimiter_pos]
    else:
        return choice

def remove_double_slash(rev):
    try:
        rev = rev.decode()
    except:
        return rev
    return rev.replace('\\\\', '\\')

def clean_regexp(rev):
    if len(rev) == 0:
        return ""
    
    r = remove_delimiter(rev)
    return remove_double_slash(r)
