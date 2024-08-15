#!/usr/bin/python

# If you're horrified by this code, never go into academia. 
# Think about this:
# You often only have a couple of months to get the code working.
# Your primary goal is often not the code but the experiments and the results.
# A HUGE portion of your time goes into writing the paper.
# You're likely not going to maintain this code, you're going to throw it away.
# Well ... this it what you get.
# It works, but at what cost. 
# Dear God, at what cost...

from ast import dump
from asyncio import unix_events
from calendar import c
import random
import string
import pickle
import json
import os
import re
import sys
import struct
import fcntl
import cProfile
import gc
import itertools
from bs4 import BeautifulSoup
from urllib.parse import urlparse, urlunparse, urljoin, parse_qs, unquote
from typing       import Set, List, Dict
from enum import Enum, unique, auto
from typing import *
from icecream import ic # type: ignore
from copy import deepcopy
from struct import *
from hashable_bytearray import *
from os.path import *
from html_parse import *

from numpy import choose
from misc import *

MAX_RANDOM_STRING_LENGTH = 8
NUM_TRIMMING_OPERATIONS = 25
MAX_CONCAT_FILES = 2
EXEC_LIMIT_INCREMENT = 0 #1000
APPLY_REDQUEEN_AFTER = 20 # how many executions before redqueen is run (to skip the calibration period)
APPLY_HTML_DUMP_AFTER = APPLY_REDQUEEN_AFTER + 1
APPLY_COVERAGE_DUMP_AFTER = APPLY_HTML_DUMP_AFTER + 1
MAX_GLOBAL_TODO = 5000
META_FILENAME = s2h("filename")
META_EXEC_LIMIT = s2h("exec_limit")
MUTATION_DELIMITERS = [HashableBytearray(x.encode()) for x in ['/', '.', '_', ',', ':', ';', ' ', '"', "'"]]
InputType = Dict[str, Dict[HashableBytearray, HashableBytearray]] # {"GET": {}, "POST": {}, "COOKIE": {}}
InputTypeConcat = List[InputType]
input_methods = ["GET", "POST", "COOKIE", "SERVER"]
empty_input: InputType = {"GET": {}, "POST": {}, "COOKIE": {}, "SERVER": {}, "meta": {}}
default_input: InputType = deepcopy(empty_input)
php_strings: List[HashableBytearray] = []
php_keyable_strings: List[HashableBytearray] = []
default_host = "localhost:8000"
default_host_url = f"http://{default_host}/"
default_filename: HashableBytearray = HashableBytearray("/var/www/html/index.php".encode())
php_filenames: List[HashableBytearray] = [default_filename]
default_server_variables: Dict[str, str] = {}
last_successful_trimmed_input: Optional[InputTypeConcat] = None
current_trimmed_input: Optional[InputTypeConcat] = None
trimming_operation_counter: int = 0
in_trimming_mode: bool = False
num_trim_operations: int = 0
first_trim: bool = True
initialized_files: List[str] = []
fuzz_todo_single: List[InputType] = []
fuzz_todo_concat: Optional[InputTypeConcat] = None
fuzz_todo_global: List[InputType] = []
global_todo_already_added: Set[int] = set()
queue_files: Set[str] = set()
php_filename_to_queue_files: Dict[HashableBytearray, Set[str]] = {}
current_executions: int = 0
redqueen_map: List[HashableBytearray] = []
redqueen_key_map: List[HashableBytearray] = []
redqueen_unmatched_map: List[Tuple[HashableBytearray, HashableBytearray]] = []
seed_cycles: Dict[str, int] = {}
seed_exec_limits: Dict[str, int] = {}
current_seed: str = ""
pinned_core: int = 0
full_trace: bool = False
redqueen_done = False
html_dump_done = False
coverage_dump_done = False
input_key_map: Dict[HashableBytearray, List[HashableBytearray]] = {}
filename_to_string_map: Dict[HashableBytearray, List[HashableBytearray]] = {}
html_dump_inputs: List[Tuple[HashableBytearray, HashableBytearray, HashableBytearray]] = []

fcntl.fcntl(sys.stdout.fileno(), fcntl.F_SETFL, os.O_NONBLOCK)

@unique
class MutationMethod(Enum):
    INSERT = auto()
    APPEND = auto()
    REPLACE = auto()
    SPLIT_REPLACE = auto()
    BYTE_MUTATE = auto()
    INTEGER = auto()
    DELETE = auto()
    BUG_TRIGGER = auto()

@unique
class BaseMutation(Enum):
    KEEP = auto()
    COPY = auto()
    SLICED_COPY = auto()
    RANDOM = auto()
    DICTIONARY = auto()
    BUG_TRIGGER = auto()

@unique
class DictionaryStrings(Enum):
    STATIC = auto()
    RUNTIME = auto()
    KEYABLE = auto()
    UNMATCHED = auto()
    WORKED_BEFORE = auto()

@unique
class FuzzOperation(Enum):
    INSERT_NEW_KEY = auto()
    DELETE_KEY = auto()
    MUTATE_VALUE = auto()
    UPLOAD = auto()

@unique
class TrimmingOperation(Enum):
    DELETE_VARIABLE = auto()
    EMPTY_VALUE = auto()
    TRIM_VALUE = auto()

base_mutation_probabilities = {
    0: # value
     {
         BaseMutation.KEEP: 0.05,
         BaseMutation.COPY: 0.05,
         BaseMutation.SLICED_COPY: 0.05,
         BaseMutation.RANDOM: 0.05,
         BaseMutation.DICTIONARY: 0.4,
         BaseMutation.BUG_TRIGGER: 0.4,
     },
    1: # key
     {
         BaseMutation.KEEP: 0.2,
         BaseMutation.COPY: 0.02,
         BaseMutation.SLICED_COPY: 0.02,
         BaseMutation.RANDOM: 0.05,
         BaseMutation.DICTIONARY: 0.7,
         BaseMutation.BUG_TRIGGER: 0.01,
     }
}

def logme(str):
    with open("/dev/shm/afl_log.txt", "a+") as f:
        f.write(f"{str}\n")

def byte_is_digit(b: int) -> bool:
    return 0x30 <= b <= 0x39

def trim_coverage_file(cov_file):
    with open(cov_file, "r", encoding='utf-8', errors='ignore') as f:
        content = sorted(list(set([x.strip() for x in f.readlines()])))
        return '\n'.join(content)

# https://stackoverflow.com/questions/4664850/how-to-find-all-occurrences-of-a-substring
def find_all(a_str, sub):
    start = 0
    tries = 0
    while tries < 10:
        tries += 1
        start = a_str.find(sub, start)
        if start == -1: return
        yield start
        start += 1

def html_inputs_to_seed(current_input, html_inputs):
    global default_input, empty_input, current_seed, input_methods
    global fuzz_todo_global
    for html_input in html_inputs:
        (target, name_value_pairs) = html_input
        target_php_files = [f for f in php_filenames if f.endswith(target)]
        current_input_filename = current_input["meta"][META_FILENAME]
        target_php_files += [current_input_filename]
        target_php_files = list(set(target_php_files))
        
        for target_php in target_php_files:
            for concat in ["single", "concat_before", "concat_after"]:
                for t in ["empty", "default", "current", "random"]:
                    if t == "empty":
                        inp = deepcopy(empty_input)
                    elif t == "default":
                        inp = deepcopy(default_input)
                    elif t == "current":
                        inp = deepcopy(current_input)
                    elif t == "random":
                        if target_php in php_filename_to_queue_files:
                            queue_file = random.choice(list(php_filename_to_queue_files[target_php]))
                        else:
                            queue_file = random.choice(list(queue_files))
                        inp = convert_seed(queue_file)[0]
                    inp["meta"][META_FILENAME] = deepcopy(target_php)
                    inp["meta"][META_EXEC_LIMIT] = EXEC_LIMIT_INCREMENT
                    for (name, value) in name_value_pairs:
                        for _type in input_methods:
                            set_input(inp, _type, name, value)
                    h = hash(input_to_HashableBytearray([inp]))
                    if h not in global_todo_already_added:
                        global_todo_already_added.add(h)
                        if concat == "concat_before":
                            fuzz_todo_global.append([inp, deepcopy(current_input)])
                        elif concat == "concat_after":
                            fuzz_todo_global.append([deepcopy(current_input), inp])
                        else:
                            fuzz_todo_global.append([inp]) # todo: make this work with concat files
    random.shuffle(fuzz_todo_global)
    fuzz_todo_global = fuzz_todo_global[:MAX_GLOBAL_TODO]

def set_input(inp: InputType, _type: str, key: HashableBytearray, value: HashableBytearray):
    if _type == "SERVER":
        # don't allow non-whitelisted items in the SERVER variable
        try:
            key_str = key.decode()
        except:
            return
        if key_str not in server_vars_whitelist and not key_str.startswith("HTTP_"):
            return
        # it makes no sense to have arrays in $_SERVER
        if "[" in key_str:
            return
    delete_input_key(inp, _type, key)
    inp[_type][key] = value

def delete_input_key(inp: InputType, _type: str, key: HashableBytearray):
    removed = False # was a key succesfully removed?
    opening_parenthesis = s2h("[")
    key_opening_parenthesis = HashableBytearray(key + opening_parenthesis)
    if opening_parenthesis in key:
        key_without_parenthesis = HashableBytearray(key[:key.rindex(opening_parenthesis)])
    else:
        key_without_parenthesis = key
    # remove key as it exists in its current form
    if inp[_type].pop(key, None) is not None:
        removed = True 
    # if key is already an array, remove the key part too
    if inp[_type].pop(key_without_parenthesis, None) is not None:
        removed = True
    # if it's not an array, remove all those that are
    for matching_key in [k for k in inp[_type].keys() if k.startswith(key_opening_parenthesis)]:
        if inp[_type].pop(matching_key, None) is not None:
            removed = True
    return removed

def input_keys(inp: InputType, input_method=None):
    methods = input_methods
    if input_method is not None:
        methods = [input_method]
    return deepcopy([vname for x in methods for (vname, _) in inp[x].items()])

def input_keys_and_values(inp: InputType):
    ret: List[HashableBytearray] = []
    values = [(vname, vcontent) for x in input_methods for (vname, vcontent) in inp[x].items()]
    for (key, val) in values:
        ret.append(key)
        ret.append(val)
    return deepcopy(ret)

def input_values(inp: InputType):
    return deepcopy([val for x in input_methods for (_, val) in inp[x].items()])

def convert_seed(seed_file: str) -> InputTypeConcat:
    with open(seed_file, "rb") as a:
        return convert_input(HashableBytearray(a.read()))

def _data_from_all_seeds(inp, func):
    global queue_files
    if len(queue_files) == 0:
        return func(inp)
    else:
        v = []
        for cur_inp in convert_seed(random.choice(list(queue_files))):
            v.extend(func(cur_inp))
        return v

def input_keys_random_seed(inp):
    return _data_from_all_seeds(inp, input_keys)

def input_values_random_seed(inp):
    return _data_from_all_seeds(inp, input_values)

def input_keys_and_values_random_seed(inp):
    return _data_from_all_seeds(inp, input_keys_and_values)

def random_substring(b: HashableBytearray):
    l = len(b)
    if l > 0:
        start = random.randint(0, l-1)
        end = random.randint(start, l-1)
        return HashableBytearray(b[start:end+1])
    else:
        return HashableBytearray()

def random_bytestring(len: Optional[int] = None, printable: bool = False) -> HashableBytearray:
    if len is None:
        len = random.randint(1, MAX_RANDOM_STRING_LENGTH)
    if printable:
        choose_from = [ord(x) for x in string.printable]
    else:
        choose_from = list(range(0, 256))
    return HashableBytearray([int(random.choice(choose_from)) for _ in range(len)])

# selects from dictionary, from bug trigger list, get_base, returns byte or random bytestring 
def mutation_string(inp: InputType, filename=None) -> bytearray:
    choice = random.choice([0,1,2,3,4])
    if choice == 0:
        new_data = get_from_dictionary(inp, filename=filename)
    elif choice == 1:
        new_data = get_base(inp, filename=filename)
    elif choice == 2:
        bug_trigger_type: str = random.choice(list(bug_trigger_magic.keys()))
        new_data = HashableBytearray(random.choice(bug_trigger_magic[bug_trigger_type]))
    elif choice == 3:
        # big chance to mutate printable chars
        if random.random() < 0.5:
            new_data = HashableBytearray([ord(random.choice(string.printable))])    
        else:
            new_data = HashableBytearray([int(random.random() * 0x100)])
    elif choice == 4:
        new_data = random_bytestring(printable = (random.random() < 0.5))
    return deepcopy(new_data)

def mutate(inp: InputType, b: HashableBytearray, filename=None) -> HashableBytearray:
    global php_strings

    mutation_method = random.choice(list(MutationMethod))
    b = deepcopy(b) # copy

    if len(b) == 0:
        # if there is nothing to mutate, just generate a random base
        b = get_base(inp, filename=filename)
    else:
        if mutation_method == MutationMethod.INSERT:
            # some chance to pick from dictionary instead of randomly generating
            start = random.randint(0, len(b)-1)
            b[start:start] = mutation_string(inp, filename=filename)
        elif mutation_method == MutationMethod.APPEND:
            delimiter = random.choice(MUTATION_DELIMITERS + [HashableBytearray("".encode())])
            b = b + delimiter + mutation_string(inp, filename=filename)
        elif mutation_method == MutationMethod.REPLACE:
            start = random.randint(0, len(b)-1)
            end = random.randint(start, len(b)-1)
            b[start:end+1] = mutation_string(inp, filename=filename)
        elif mutation_method == MutationMethod.SPLIT_REPLACE:
            select_from = [d for d in MUTATION_DELIMITERS if d in b]
            if len(select_from) == 0:
                start = random.randint(0, len(b)-1)
                end = random.randint(start, len(b)-1)
                b[start:end+1] = mutation_string(inp, filename=filename)
            else:
                delimiter = random.choice(select_from)
                positions = list(find_all(b, delimiter))
                _src = random.choice(range(len(positions)))
                src = positions[_src]
                if _src == len(positions)-1:
                    # last occurence selected, replace string until end
                    dst = len(b)
                else:
                    # otherwise replace until next delimiter occurrence
                    dst = positions[_src+1]            
                b[src+1:dst] = mutation_string(inp, filename=filename)
        elif mutation_method == MutationMethod.DELETE:
            if random.random() < 0.5:
                # just delete something from the tail
                start = random.randint(0, len(b)-1)
                end = len(b)-1
            else:
                # delete from anywhere
                start = random.randint(0, len(b)-1)
                end = random.randint(start, len(b)-1)
            del b[start:end+1]
        elif mutation_method == MutationMethod.BYTE_MUTATE:
            # big chance to mutate printable chars
            if random.random() < 0.5:
                pos = random.randint(0, len(b)-1)
                b[pos] = ord(random.choice(string.printable))    
            else:
                pos = random.randint(0, len(b)-1)
                b[pos] = int(random.random() * 0x100)
        elif mutation_method == MutationMethod.INTEGER:
            base_i = 0
            # does it look like a digit? php sees strings that start with digits as numbers
            # and don't forget negative values
            if byte_is_digit(b[0]):
                base_i = int(''.join([chr(x) for x in b if byte_is_digit(x)]))
            elif len(b) > 1 and b[0] == '-' and byte_is_digit(b[1]):
                base_i = -int(''.join([chr(x) for x in b[1:] if byte_is_digit(x)]))
            # big chance to choose small numbers
            if random.random() < 0.5:
                i = random.randint(-128, 128)
            else:
                i = random.randint(-65536, 65536)
            # todo: don't just replace everything with the number, find numbers in b and specifically mutate those
            b = HashableBytearray(str(base_i + i).encode())
        elif mutation_method == MutationMethod.BUG_TRIGGER:
            bug_trigger_type: str = random.choice(list(bug_trigger_magic.keys()))
            b = HashableBytearray(deepcopy(random.choice(bug_trigger_magic[bug_trigger_type])))
    return b

def get_from_dictionary(inp: InputType, filename=None, is_key=False) -> HashableBytearray:
    global php_strings, php_keyable_strings, current_seed
    global redqueen_map, redqueen_key_map
    # probability which string list to select from
    choose_from = dict({DictionaryStrings.STATIC: 1, \
                        DictionaryStrings.RUNTIME: 1, \
                        DictionaryStrings.KEYABLE: 3 if is_key else 2, \
                        DictionaryStrings.UNMATCHED: 3 if not is_key else 2, \
                        DictionaryStrings.WORKED_BEFORE: 1})
    m: Dict[DictionaryStrings, List[Any]] = {
            DictionaryStrings.STATIC: php_strings,
            DictionaryStrings.RUNTIME: [],
            DictionaryStrings.KEYABLE: php_keyable_strings + input_key_map.get(filename, []),
            DictionaryStrings.UNMATCHED: [],
            DictionaryStrings.WORKED_BEFORE: filename_to_string_map.get(filename, [])
        }
    
    if len(php_strings) == 0:
        del choose_from[DictionaryStrings.STATIC]
    
    if len(filename_to_string_map.get(filename, [])) == 0:
        del choose_from[DictionaryStrings.WORKED_BEFORE]
    
    if len(redqueen_map) == 0:
        del choose_from[DictionaryStrings.RUNTIME]
        del choose_from[DictionaryStrings.UNMATCHED]
    else:
        m.update({
            DictionaryStrings.RUNTIME: redqueen_map,
            DictionaryStrings.KEYABLE: redqueen_key_map,
            DictionaryStrings.UNMATCHED: redqueen_unmatched_map,
        })
        if len(redqueen_map) == 0:
            del choose_from[DictionaryStrings.RUNTIME]
        if len(redqueen_key_map) == 0:
            if len(php_keyable_strings) > 0:
                m[DictionaryStrings.KEYABLE] = php_keyable_strings + input_key_map.get(filename, [])
            else:
                del choose_from[DictionaryStrings.KEYABLE]
        if len(redqueen_unmatched_map) == 0:
            del choose_from[DictionaryStrings.UNMATCHED]


    if len(choose_from) == 0:
        return random_bytestring(printable=True)
    else:
        strings_list = random.choices(list(choose_from.keys()), weights=list(choose_from.values()), k=1)[0]
        if len(m[strings_list]) > 0:
            if strings_list == DictionaryStrings.UNMATCHED:
                # do a partial match
                # try to find matching string n times
                for _ in range(10):
                    unmatched_tuple: Tuple[HashableBytearray, HashableBytearray] = random.choice(m[strings_list])
                    if len(unmatched_tuple[0]) == 0 and len(unmatched_tuple[1]) == 0:
                        continue
                    # if one of the strings is empty, set the whole string
                    if len(unmatched_tuple[0]) == 0 or len(unmatched_tuple[1]) == 0:
                        replace_with_this: HashableBytearray = unmatched_tuple[1 if len(unmatched_tuple[0]) == 0 else 0]
                        return HashableBytearray(deepcopy(replace_with_this))
                    else:
                        replace_this_index = random.choice([0, 1])
                        replace_this: HashableBytearray = unmatched_tuple[replace_this_index]
                        if random.random() < 0.5:
                            with_this: HashableBytearray = unmatched_tuple[0 if replace_this_index == 1 else 1]
                        else:
                            # 50% chance to replace this part of the string with something else
                            with_this = mutation_string(inp, filename=filename)
                        all_keys_and_values = input_keys_and_values(inp)
                        matching_keys_and_values = [x for x in all_keys_and_values if replace_this in x]
                        if len(matching_keys_and_values) > 0:
                            match_choice = random.choice(matching_keys_and_values)
                            positions = list(find_all(match_choice, replace_this))
                            match_pos = random.choice(positions)
                            match_pos_end = match_pos+len(replace_this)
                            match_choice[match_pos:match_pos_end] = with_this
                            return HashableBytearray(match_choice)
                        else:
                            continue
                return deepcopy(random.choice(m[strings_list])[random.choice([0, 1])])
            else:
                return deepcopy(random.choice(m[strings_list]))
        else:
            return random_bytestring(printable=True)

def get_base(inp: InputType, default: Optional[HashableBytearray] = None, filename=None, is_key: bool = False, is_value: bool = False) -> HashableBytearray:
    global php_strings, base_mutation_probabilities

    choose_from = deepcopy(base_mutation_probabilities[is_key])
    # if default value is given, it can be chosen too
    if default is None:
        del choose_from[BaseMutation.KEEP]
    # select from our own keys or from all keys?
    if random.random() < 0.5:
        # select from our own keys and values
        if is_key:
            kv = input_keys(inp)
        elif is_value:
            kv = input_values(inp)
        else:
            kv = input_keys_and_values(inp)
    else:
        # select from random seed in queue
        # if it worked for someone else, it might work for us too
        if is_key:
            kv = input_keys_random_seed(inp)
        elif is_value:
            kv = input_values_random_seed(inp)
        else:
            kv = input_keys_and_values_random_seed(inp)
    if len(kv) == 0:
        del choose_from[BaseMutation.COPY]
        del choose_from[BaseMutation.SLICED_COPY]
    mutation: BaseMutation = random.choices(list(choose_from.keys()), weights=list(choose_from.values()), k=1)[0]
    base: HashableBytearray = HashableBytearray()
    if   mutation == BaseMutation.KEEP and default is not None:
        base = deepcopy(default)
    elif mutation == BaseMutation.COPY:
        base = random.choice(kv)
    elif mutation == BaseMutation.SLICED_COPY:
        base = random.choice(kv)
        base = random_substring(base)
    elif mutation == BaseMutation.RANDOM:
        if random.random() < 0.9:
            base = random_bytestring(printable=True)
        else:
            base = random_bytestring()
    elif mutation == BaseMutation.DICTIONARY:
        if len(php_strings) > 0:
            base = get_from_dictionary(inp, filename=filename, is_key=is_key)
        else:
            base = random_bytestring(printable=True)
    elif mutation == BaseMutation.BUG_TRIGGER:
        bug_trigger_type: str = random.choice(list(bug_trigger_magic.keys()))
        base = HashableBytearray(deepcopy(random.choice(bug_trigger_magic[bug_trigger_type])))
    else:
        raise Exception("never should have reached this")
    return base

def pickle_loads(buf: HashableBytearray):
    return pickle.loads(buf)

def convert_input(buf: HashableBytearray) -> InputTypeConcat:
    inp: InputTypeConcat
    try:
        inp = deepcopy(pickle_loads(buf))
    except:
        inp = [deepcopy(default_input)]
    
    if not isinstance(inp, list):
        inp = [deepcopy(default_input)]
    return inp

def input_to_HashableBytearray(inp_list: InputTypeConcat, max_size = None) -> HashableBytearray:
    ret_bytes = HashableBytearray(pickle.dumps(inp_list))
    if(max_size is not None and len(ret_bytes) > max_size):
        ret_bytes = HashableBytearray(pickle.dumps([default_input]))
    return ret_bytes

def init(init_seed):
    global php_filenames, default_filename, default_input
    global php_strings, current_seed
    global php_keyable_strings, default_server_variables
    global pinned_core, full_trace, pr

    current_seed = deepcopy(init_seed)
    if "PHP_DATA" in os.environ:
        php_data_dir = os.environ["PHP_DATA"]
        with open(join(php_data_dir, "filenames.json"), "rb") as f:
            fd = json.load(f)
            php_filenames = [HashableBytearray(s.strip().encode()) for s in fd["fuzzable"]]
        with open(join(php_data_dir, "extract.json"), "rb") as f:
            php_extract = json.load(f)
            php_strings                     = [HashableBytearray(s.encode()) for s in php_extract["strings"]]
            # php strings that could be keys (no weird characters)
            php_keyable_strings             = [HashableBytearray(s.encode()) for s in php_extract["strings"] if re.match("^[A-Za-z0-9_-]*$", s) is not None]
    if "PIN_CORE" in os.environ:
        pinned_core = int(os.environ["PIN_CORE"])
    if "DISABLE_COVERAGE_TRIMMING" in os.environ:
        full_trace = True
    ic(pinned_core)
    if "START_FILE" in os.environ:
        default_filename = HashableBytearray(os.environ["START_FILE"].encode())
    if default_filename not in php_filenames:
        default_filename = HashableBytearray("/var/www/html/browser_data.php".encode())
        if default_filename not in php_filenames:
            default_filename = random.choice(php_filenames)
    default_input["meta"][META_FILENAME] = default_filename
    default_input["meta"][META_EXEC_LIMIT] = EXEC_LIMIT_INCREMENT
    if "BROWSER_DATA" in os.environ:
        with open(os.environ["BROWSER_DATA"], "r") as f:
            browser_data_export = json.loads(f.read())
            default_server_variables = browser_data_export["SERVER"] #{key: string_urlencode(value) for (key, value) in browser_data_export["SERVER"].items()}
            standard_cookies = browser_data_export["COOKIE"]
            try:
                ic(standard_cookies)
            except:
                pass
            # when the cookies are empty, it's actually an empty list instead of dict
            if isinstance(standard_cookies, dict):
                for (vname,vval) in standard_cookies.items():
                    default_input["COOKIE"][HashableBytearray(vname.encode())] = HashableBytearray(vval.encode())
            # most php applications use mod_rewrite, make it easier for us to mutate this
            default_input["SERVER"][s2h("REQUEST_URI")] = HashableBytearray()
            try:
                ic(default_input)
            except:
                pass

def apply_redqueen_dump(dump):
    global current_seed, redqueen_map, redqueen_key_map, redqueen_unmatched_map
    strings: List[HashableBytearray] = list()
    key_strings: List[HashableBytearray] = list()
    preg_matches: List[HashableBytearray] = list()
    unmatched_strings: List[Tuple[HashableBytearray, HashableBytearray]] = list()
    rq = parse_redqueen_file(dump)
    strings = list(set(rq["strings"]))
    key_strings = list(set(rq["key_strings"]))
    preg_matches = list(set(rq["preg_matches"]))
    unmatched_strings = list(set(rq["unmatched_strings"]))
    redqueen_map = strings
    redqueen_key_map = key_strings
    redqueen_unmatched_map = unmatched_strings

def fuzz(buf: HashableBytearray, add_buf: HashableBytearray, max_size: int) -> HashableBytearray:
    global initialized_files, fuzz_todo_concat, fuzz_todo_single
    global current_seed, full_trace, current_executions, redqueen_done
    global html_dump_inputs, fuzz_todo_global, redqueen_map, redqueen_key_map
    global html_dump_done, coverage_dump_done
    inp_list: InputTypeConcat = convert_input(buf)

    min_exec_limit = min([i["meta"][META_EXEC_LIMIT] for i in inp_list])
    for inp in inp_list:
        # opportunity to get more executions if we cycled
        inp["meta"][META_EXEC_LIMIT] = min_exec_limit + seed_cycles.get(current_seed, 0)*EXEC_LIMIT_INCREMENT
        # and every potential child seed (when new coverage is found) gets more coverage
        # so it increases with every new generation to get deeper into code
        inp["meta"][META_EXEC_LIMIT] += EXEC_LIMIT_INCREMENT

    current_executions += 1

    # if this was not fuzzed before, let's first dump the redqueen info before mutating
    if current_executions == 1:
        # the very first execution should have no exec limit
        return input_to_HashableBytearray(inp_list, max_size)
    elif current_executions == APPLY_REDQUEEN_AFTER:
        redqueen_done = False
        # at the 100th execution, dump redqueen data (to make sure we skip the calibration phase)
        return input_to_HashableBytearray(inp_list, max_size)
    elif current_executions == APPLY_HTML_DUMP_AFTER:
        html_dump_done = False
        return input_to_HashableBytearray(inp_list, max_size)
    # elif current_executions == APPLY_COVERAGE_DUMP_AFTER:
    #     coverage_dump_done = False
    #     return input_to_HashableBytearray(inp_list, max_size)

    # if the seed was fuzzed for the first time, read redqueen strings
    redqueen_dump_path = abspath(f"{dirname(current_seed)}/../../workdir/dump/strings_{pinned_core}")
    if isfile(redqueen_dump_path):
        apply_redqueen_dump(redqueen_dump_path)
        os.system(f"mv {redqueen_dump_path} /dev/shm/rq/{basename(current_seed)}.rq")
        #os.remove(redqueen_dump_path)
        # don't mutate it any further right now, just get the redqueen strings first
        return input_to_HashableBytearray(inp_list, max_size)

    html_dump_path = abspath(f"{dirname(current_seed)}/../../workdir/dump/html_{pinned_core}")
    if isfile(html_dump_path):
        # try:
        #     ic(html_dump_path)
        # except:
        #     pass
        with open(html_dump_path, "r", encoding='utf-8', errors='ignore') as f:
            # sometimes reading the file throws an error
            try:
                html_content = f.read()
            except:
                pass
            else:
                html_dump_inputs = html_extract_inputs(html_content)
                # try:
                #     ic(html_dump_inputs)
                # except:
                #     pass
                html_dump_inputs_hb = html_inputs_to_hb(html_dump_inputs)
                html_inputs_to_seed(inp_list[0], html_dump_inputs_hb)
                for html_input in html_dump_inputs_hb:
                    (target, key_value_pairs) = html_input
                    redqueen_map.append(target)
                    for (key, value) in key_value_pairs:
                        logme(f"html extracted {key} = {value}")
                        redqueen_key_map.append(key)
                        redqueen_map.append(value)
        os.system(f"mv {html_dump_path} /dev/shm/rq/{basename(current_seed)}.html")

    if len(initialized_files) < len(php_filenames) and current_executions > APPLY_HTML_DUMP_AFTER:
        # first mode is to execute all PHP scripts at least once
        inp_list = [deepcopy(default_input)]
        inp = inp_list[0]
        php_filenames_str: List[str] = [x.decode() for x in php_filenames]
        initialize_filename: str = random.choice(list(set(php_filenames_str) - set(initialized_files)))
        initialized_files.append(initialize_filename)
        inp["meta"][META_FILENAME] = HashableBytearray(initialize_filename.encode())
        return input_to_HashableBytearray(inp_list, max_size)

    # global todos left?
    if len(fuzz_todo_global) > 0 and random.random() < 0.2:
        inp_list = fuzz_todo_global.pop()
        return input_to_HashableBytearray(inp_list, max_size)
    
    # concat todos left?
    if len(fuzz_todo_single) > 0:
        inp_list = [fuzz_todo_single.pop()]
    elif fuzz_todo_concat is not None:
        inp_list = fuzz_todo_concat
        fuzz_todo_concat = None
    else:

        # concat another seed file?
        if len(inp_list) < MAX_CONCAT_FILES and random.random() < 0.1 and len(queue_files) > 0:
            add_buf_file = random.choice(list(queue_files))
            with open(add_buf_file, "rb") as a:
                add_inp_list: InputTypeConcat = convert_input(HashableBytearray(a.read()))
            inp_list.extend(add_inp_list)
            random.shuffle(inp_list)

        fuzz_loops = random.randrange(1, 3)
        for _ in range(fuzz_loops):
            inp = random.choice(inp_list)
            
            current_filename = inp["meta"][META_FILENAME]

            upload_chance = 50 if is_upload_mode(inp) else 3
            fo = {FuzzOperation.INSERT_NEW_KEY: 48, FuzzOperation.MUTATE_VALUE: 48, FuzzOperation.DELETE_KEY: 1, FuzzOperation.UPLOAD: upload_chance} 
            choice = random.choices(list(fo.keys()), weights=list(fo.values()), k=1)[0]
            if len(input_keys(inp)) == 0:
                choice = FuzzOperation.INSERT_NEW_KEY
            if choice == FuzzOperation.INSERT_NEW_KEY:
                if random.random() < 0.9:
                    # mostly, just a new key name from dictionary
                    new_variable_name = get_from_dictionary(inp, filename=current_filename, is_key=True)
                else:
                    # turn this key to ht[index] because PHP sometimes requires an array input (i.e., "index.php?abc[0]=bla")
                    variable_names = input_keys(inp)
                    if len(variable_names) > 0:
                        new_variable_name = random.choice(variable_names)
                        index = get_from_dictionary(inp, filename=current_filename, is_key=True)
                        # turn this to ht[index] because PHP sometimes requires array 
                        new_variable_name = new_variable_name + s2h("[") + index + s2h("]")
                    else:
                        new_variable_name = get_from_dictionary(inp, filename=current_filename, is_key=True)
                new_variable_value = get_base(inp, default=None, filename=current_filename, is_key=False, is_value=True)
                if random.random() < 0.05:
                    new_variable_name = mutate(inp, new_variable_name, filename=current_filename)
                # add this variable for all current types
                # as this makes sense in PHP
                # trimming will remove the unwanted ones anyway
                for _type in input_methods:
                    set_input(inp, _type, new_variable_name, new_variable_value)
            elif choice == FuzzOperation.DELETE_KEY:
                variable_names = input_keys(inp)
                chosen_variable_name = random.choice(variable_names)
                randomized_input_methods = list(input_methods)
                random.shuffle(randomized_input_methods)
                for mutation_input_type in randomized_input_methods:
                    if delete_input_key(inp, mutation_input_type, chosen_variable_name): 
                        # if the key exists and we remove it, we are done
                        break
            elif choice == FuzzOperation.MUTATE_VALUE:
                # get current keys and all keys seen in other seed files for this php file
                variable_names = input_keys(inp) + input_key_map.get(current_filename, [])
                chosen_variable_name = random.choice(variable_names)
                # sometimes just having a new base is enough, without mutating it
                if random.random() < 0.5:
                    randomized_input_methods = list(input_methods)
                    random.shuffle(randomized_input_methods)
                    for mutation_input_type in randomized_input_methods:
                        if chosen_variable_name in inp[mutation_input_type]:
                            set_input(inp, mutation_input_type, chosen_variable_name, mutate(inp, inp[mutation_input_type][chosen_variable_name], filename=current_filename))
                            break
                else:
                    # todo: set default to previous value
                    chosen_variable_value = get_base(inp, default=None, filename=current_filename, is_key=False, is_value=True)
                    mutation_input_type = random.choice(input_methods)
                    set_input(inp, mutation_input_type, chosen_variable_name, chosen_variable_value) 
            elif choice == FuzzOperation.UPLOAD:
                if s2h("CONTENT_TYPE") not in inp["SERVER"]:
                    inp["SERVER"][s2h("CONTENT_TYPE")]          = s2h('multipart/form-data; boundary=---------------------------196539603416852482923876057105')
                if s2h("CONTENT_DISPOSITION") not in inp["SERVER"]:
                    inp["SERVER"][s2h("CONTENT_DISPOSITION")]   = s2h("form-data")
                if s2h("UPLOAD_KEY") not in inp["SERVER"]:
                    inp["SERVER"][s2h("UPLOAD_KEY")]            = get_from_dictionary(inp, filename=current_filename, is_key=True)
                if s2h("UPLOAD_FILENAME") not in inp["SERVER"]:
                    inp["SERVER"][s2h("UPLOAD_FILENAME")]       = get_base(inp, default=None, filename=current_filename, is_key=False, is_value=True)
                if s2h("UPLOAD_CONTENT_TYPE") not in inp["SERVER"]:
                    inp["SERVER"][s2h("UPLOAD_CONTENT_TYPE")]   = get_base(inp, default=None, filename=current_filename, is_key=False, is_value=True)
                if s2h("UPLOAD_CONTENT") not in inp["SERVER"]:
                    inp["SERVER"][s2h("UPLOAD_CONTENT")]        = get_base(inp, default=None, filename=current_filename, is_key=False, is_value=True)
            else:
                raise Exception("Should never reached this")

            # merge with other seed file?
            if random.random() < 0.05 and len(queue_files) > 0:
                add_buf_file = random.choice(list(queue_files))
                with open(add_buf_file, "rb") as a:
                    add_inp_list: InputTypeConcat = convert_input(HashableBytearray(a.read()))
                add_inp = random.choice(add_inp_list)
                for mutation_input_type in input_methods:
                    for variable_name in input_keys(add_inp):
                        if variable_name in add_inp[mutation_input_type]:
                            set_input(inp, mutation_input_type, variable_name, add_inp[mutation_input_type][variable_name])    

        # if there are multiple PHP files concatenated, maybe one of them on their own can already get the same coverage
        inp_list_len = len(inp_list)
        if inp_list_len > 1:
            if inp_list_len > MAX_CONCAT_FILES:
                inp_list_cpy = deepcopy(inp_list)
                random.shuffle(inp_list_cpy)
                inp_list = inp_list_cpy[0:MAX_CONCAT_FILES]    
            fuzz_todo_single.extend(inp_list)
            fuzz_todo_concat = inp_list
            inp_list = [fuzz_todo_single.pop()]
    
    return input_to_HashableBytearray(inp_list, max_size)

def describe(max_description_length: int):
    return b"php"[:max_description_length]

def post_process(buf: HashableBytearray, exec_limit=None) -> HashableBytearray:
    global default_host_url, default_server_variables, seed_cycles
    global current_seed, current_executions, in_trimming_mode
    global redqueen_done, html_dump_done, default_filename
    global coverage_dump_done
    inp_list: InputTypeConcat = convert_input(buf)

    envs = input_to_env(inp_list, default_filename, default_server_variables)
    if not in_trimming_mode and current_executions == APPLY_REDQUEEN_AFTER:
        # sometimes doing redqueen produces a hang, so we get stuck in a loop
        # make sure we don't do redqueen twice in a row to avoid looping
        if not redqueen_done:
            # activate redqueen mode
            envs["config"]["REDQUEEN"] = str(pinned_core)
            # webfuzz hack, enable coverage too
            
            redqueen_done = True
    if not in_trimming_mode and current_executions == APPLY_HTML_DUMP_AFTER:
        if not html_dump_done:
            # activate html_dump mode
            envs["config"]["HTML_DUMP"] = "1"
            html_dump_done = True

    if exec_limit is None:
        envs["config"]["EXEC_LIMIT"] = str(inp_list[0]["meta"][META_EXEC_LIMIT]) 
    else:
        envs["config"]["EXEC_LIMIT"] = str(exec_limit)
        
    return HashableBytearray(json.dumps(envs).encode("ascii")) + HashableBytearray([0x00])

def init_trim(buf):
    global last_successful_trimmed_input, trimming_operation_counter, current_trimmed_input, first_trim
    global input_methods, num_trim_operations, in_trimming_mode
    in_trimming_mode = True
    last_successful_trimmed_input = convert_input(buf)
    current_trimmed_input = deepcopy(last_successful_trimmed_input)
    trimming_operation_counter = 0
    if first_trim or len(buf) == 0: # bugfix for afl++, I'm guessing a division by zero somewhere
        first_trim = False
        in_trimming_mode = False
        num_trim_operations = 0
    else:
        num_trim_operations = sum([len(input_keys(x)) for x in last_successful_trimmed_input])*NUM_TRIMMING_OPERATIONS
    return num_trim_operations

def trim():
    global last_successful_trimmed_input, input_methods, current_trimmed_input
    trimmed_ret_list: InputTypeConcat = deepcopy(last_successful_trimmed_input)

    # delete concat file?
    if len(trimmed_ret_list) > 1 and random.random() < 0.05:
        random.shuffle(trimmed_ret_list)
        trimmed_ret_list = trimmed_ret_list[0:len(trimmed_ret_list)-1]
    else:
        trimmed_ret: InputType = random.choice(trimmed_ret_list)

        # get all variables
        variables = input_keys(trimmed_ret)
        if len(variables) == 0:
            return input_to_HashableBytearray(trimmed_ret)
        randomized_input_methods = deepcopy(input_methods)
        random.shuffle(randomized_input_methods)
        chosen_variable = None
        chosen_input_method = None
        for input_method in randomized_input_methods:
            variables_for_this_input_type = input_keys(trimmed_ret, input_method=input_method)
            if len(variables_for_this_input_type) > 0:
                chosen_variable = random.choice(variables_for_this_input_type)
                chosen_input_method = input_method
                break
        assert(chosen_variable is not None)
        assert(chosen_input_method is not None)
        trim_op = random.choice(list(TrimmingOperation))
        if trim_op == TrimmingOperation.DELETE_VARIABLE:
            upload_mode = is_upload_mode(trimmed_ret)
            if upload_mode:
                try:
                    chosen_variable_str = chosen_variable.decode()
                except:
                    chosen_variable_str = None
                if chosen_variable_str is None or chosen_variable_str not in server_keep_after_trimming:
                    delete_input_key(trimmed_ret, chosen_input_method, chosen_variable)
            else:
                delete_input_key(trimmed_ret, chosen_input_method, chosen_variable)
        elif trim_op == TrimmingOperation.EMPTY_VALUE:
            # sometimes just setting a key to an empty value is enough (i.e., when a key was newly discovered)
            set_input(trimmed_ret, chosen_input_method, chosen_variable, HashableBytearray())
        elif trim_op == TrimmingOperation.TRIM_VALUE:
            # randomly trim the value to make it as short as possible
            trimmed_content = HashableBytearray(deepcopy(trimmed_ret[chosen_input_method][chosen_variable]))
            if len(trimmed_content) > 0:
                start = random.randint(0, len(trimmed_content)-1)
                end = random.randint(start, len(trimmed_content)-1)
                del trimmed_content[start:end+1]
                set_input(trimmed_ret, input_method, chosen_variable, trimmed_content)
        else:
            raise Exception("should never reach this")

        current_trimmed_input = trimmed_ret_list
    return input_to_HashableBytearray(trimmed_ret_list)

def post_trim(success):
    global trimming_operation_counter, last_successful_trimmed_input, current_trimmed_input
    global in_trimming_mode, num_trim_operations
    if success:
        last_successful_trimmed_input = current_trimmed_input
    trimming_operation_counter += 1
    if trimming_operation_counter >= num_trim_operations:
        # update filename to key mapping
        for inp in current_trimmed_input:
            filename = inp["meta"][META_FILENAME]
            input_key_map[filename] = list(set(input_key_map.get(filename, []) + input_keys(inp)))
            filename_to_string_map[filename] = list(set(filename_to_string_map.get(filename, []) + input_keys_and_values(inp)))
        in_trimming_mode = False
    return trimming_operation_counter

def queue_get(fn):
    global current_seed, seed_cycles, current_executions
    global redqueen_map, redqueen_key_map, redqueen_unmatched_map
    current_seed = deepcopy(fn)
    seed_cycles[current_seed] = seed_cycles.get(current_seed, -1) + 1
    current_executions = 0
    redqueen_map = []
    redqueen_key_map = []
    redqueen_unmatched_map = []
    gc.collect()
    return True

def queue_new_entry(filename_new_queue, filename_orig_queue):
    global queue_files, php_filename_to_queue_files
    queue_files.add(deepcopy(filename_new_queue))
    d = convert_seed(filename_new_queue)[0]
    if d["meta"][META_FILENAME] not in php_filename_to_queue_files:
        php_filename_to_queue_files[d["meta"][META_FILENAME]] = set([filename_new_queue])
    else:
        php_filename_to_queue_files[d["meta"][META_FILENAME]].add(filename_new_queue)
    return False

def introspection():
    return string

def deinit():  # optional for Python
    pass
