#!/usr/bin/env python3.8
""" Using webFuzz for manual fuzzing. *NOT COMPLETED*

This module provides an interactive way for the user to fuzz a
web application. The source code of this module is heavily commented
in order to provide a detailed documentation for the reader. The code
is written python3.8.
"""
import http.client
import signal
import random
import time
import logging
import requests
import glob
import os
from bs4 import BeautifulSoup
from datetime import datetime
from pyfiglet import figlet_format
from termcolor import cprint
from urllib.request import urlopen

# user modules
from .browser import get_cookies
from .environment import env
from .mutator import Mutator
from .node import Node
from .parser import Parser

"""*NOT COMPLETED*"""

def xss_fuzzing_payloads_all(urlHack, inputs):
    """
        Read data from all txt files in the directory containing
        xss fuzzing payloads. We read as many lines needed from the
        file to fill all the input fills given as a parameter to
        the method.
    """
    os.chdir(r'./Payloads/XSS_fuzzing_payloads')
    myFiles = glob.glob('*.txt')
    for i in myFiles:
        f = open(i, "r")
        line = f.readline()
        while line:
            data = {}
            for j in inputs:
                data[str(j)] = line
                line = f.readline()
            # if not line:
            #	break
            response = requests.post(urlHack, data=dict(data))  # headers=headers,
            logging.info(
                "Status: {} Headers: {}\nResponse: {}\nInput: {}\n".format(response.status_code, response.headers,
                                                                           response.content, data))
        f.close()


def xss_fuzzing_payloads_one():
    """
        Return a single XSS payload from a random file in the directory.
        Directory contains various text files with XSS payloads.
    """
    file = random.choice(os.listdir("./Payloads/XSS_fuzzing_payloads"))  # random file name from directory
    f = open("./Payloads/XSS_fuzzing_payloads/" + file, "r")  # open the random file
    line = f.readlines()  # convert the lines of the file to a list
    xss_line = random.choice(line)  # choose a random line from the file
    f.close()
    return xss_line


def fuzzing_data_random(max_length=20, char_start=32, char_range=32):
    """
       A string of up to `max_length` characters
       in the range [`char_start`, `char_start` + `char_range`]
    """
    string_length = random.randrange(0, max_length + 1)
    out = ""
    for i in range(0, string_length):
        out += chr(random.randrange(char_start, char_start + char_range))
    return out


'''
def delete_random_character(s): # CHECK FUNCTIONALITY & ADD TO API
    """Returns s with a random character deleted"""
    if s == "":
        return s

    pos = random.randint(0, len(s) - 1)
    # print("Deleting", repr(s[pos]), "at", pos)
    return s[:pos] + s[pos + 1:]

def insert_random_character(s): # CHECK FUNCTIONALITY & ADD TO API
    """Returns s with a random character inserted"""
    pos = random.randint(0, len(s))
    random_character = chr(random.randrange(32, 127))
    # print("Inserting", repr(random_character), "at", pos)
    return s[:pos] + random_character + s[pos:]    

def flip_random_character(s):  # CHECK FUNCTIONALITY & ADD TO API
    """Returns s with a random bit flipped in a random position"""
    if s == "":
        return s

    pos = random.randint(0, len(s) - 1)
    c = s[pos]
    bit = 1 << random.randint(0, 6)
    new_c = chr(ord(c) ^ bit)
    # print("Flipping", bit, "in", repr(c) + ", giving", repr(new_c))
    return s[:pos] + new_c + s[pos + 1:]

def mutate(s):  # CHECK FUNCTIONALITY & ADD TO API
    """Return s with a random mutation applied"""
    mutators = [
        delete_random_character,
        insert_random_character,
        flip_random_character
    ]
    mutator = random.choice(mutators)
    # print(mutator)
    return mutator(s)
'''


class FuzzerManual:
    def __init__(self):
        """
        Constructor for a manual webFuzz instance.
        """
        args = env.args

        # Print terminal text banner.
        cprint(figlet_format("webFuzz", font="doom"), 'blue', attrs=['bold'])

        # Log file creation.
        dt = datetime.now()
        log_file = f"./log/webFuzz_manual_{dt.day}-{dt.month}_{dt.hour}:{dt.minute}.log"
        file_handler = logging.FileHandler(log_file)  # Configure the root logger to write to a file.

        log_format = logging.Formatter('%(asctime)s %(levelname)s %(funcName)s(%(lineno)d) %(message)s')
        file_handler.setFormatter(log_format)

        # Log level definition from argument (-v).
        # If the log level of a log is lower than logger level specified here, the log will be ignored.
        if args.verbose == 0:
            file_handler.setLevel(logging.ERROR)
        elif args.verbose == 1:
            file_handler.setLevel(logging.WARNING)
        elif args.verbose == 2:
            file_handler.setLevel(logging.INFO)
        else:
            file_handler.setLevel(logging.DEBUG)

        # Initialise a unique logger for each module and attach it to the FileHandler.
        for module in [__name__, 'mutator', 'node', 'parser']:
            module_logger = logging.getLogger(module)
            module_logger.addHandler(file_handler)
            module_logger.setLevel(logging.DEBUG)

        logger = get_logger()
        logger.debug(args)

        # Register an OS alarm signal if argument timeout is specified(-t).
        signal.signal(signal.SIGALRM, _timeout)
        if args.timeout > 0:
            signal.alarm(args.timeout)

        http.client._MAXHEADERS = 100000

        self._session = requests.Session()

        if args.session:
            cookies = {cookie['name']: cookie['value'] for cookie in get_cookies(args.URL)}

            self._session.cookies.update(cookies)
            logger.info("got cookies: %s", cookies)

        self._session.headers.update({
            'user-agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 '
                          'Safari/537.36',
            'accept-language': 'en-GB,en;q=0.9,en-US;q=0.8,el;q=0.7',
            'accept': 'text/html,application/xhtml+xml'})
        self._mutator = Mutator()
        self._node_list = Node_list(blocklist=args.block,
                                    crawler_unseen=set([Node(url=args.URL,
                                                             method=Http_method.GET)]))

        self._parser = Parser(args.URL, self._node_list._mutator.xss_payloads)

        self._pending_nodes = [{"url": args.URL, "method": "GET", "params": {}}]
        self._node_list = []


    def main():
        # url = input("Please enter URL you would like to fuzz: ")
        # url = "http://localhost:8080/Vulnerable_websites/xss.html"  # You can change to whatever your url is and comment out previous line.
        # urlHack = "http://localhost:8080/Vulnerable_websites/xss.hack"

        print("Trying to connect to {}...".format(url))
        try:  # Check if we can connect to url given.
            req = urlopen(url)
            headers = req.getheaders()
            page = req.read()
            print("Connected succesfully")
        except:
            print("Error connecting to the given URL.\nExiting...")
            raise

        soup = BeautifulSoup(page, 'html.parser')  # Parse the whole html file for manipulation.

        inputs, serverSideFile, requestMethod = extract_form_fields(soup)  # All the input fields are here.
        requestMethod = requestMethod.upper()
        if len(inputs) == 0:  # If no input fields then there is nothing to fuzz and we exit.
            print("No input fields for fuzzing at given URL.\nExiting...")
            exit()
        else:
            print("Server side file: " + serverSideFile)
            print("Request method: " + requestMethod)
            print("Here are the following input fields found in the given URL:")
            print("==> {} <==".format(inputs))

        serverSideFile = url[:url.rfind('/')] + "/" + serverSideFile

        exit_flag = True

        while (exit_flag):  # We repeat the following process untill user desires to exit.

            all_fields = input("Would you like to fuzz every input field(Y/N): ").upper()[0]

            if all_fields == "Y":  # Send fuzzed data to all input fields.

                print("Choose one of the following methods to fuzz:")
                print("(1) Use all the ready made frequent XSS payloads and logg responses")
                print("(2) Get one random ready made frequent XSS payloads and logg responses")
                print("(3) Generate random data and logg response")
                ans = input()

                if ans == "1":
                    xss_fuzzing_payloads_all(serverSideFile, inputs)  # Send XSS payloads
                elif ans == "2" or ans == "3":
                    # while(1):
                    data = {}
                    s_time = time.time()

                    for j in inputs:
                        if ans == "2":
                            data[str(j)] = str(xss_fuzzing_payloads_one())
                        else:
                            data[str(j)] = fuzzing_data_random()

                    # headers = {'Content-Type': 'multipart/form-data;', 'Accept': '*/*'}
                    print("Data sent: {}".format(data))
                    if requestMethod == "POST":
                        response = requests.post(serverSideFile, data=dict(data))  # headers=headers,
                    elif requestMethod == "GET":
                        response = requests.get(serverSideFile, params=dict(data))
                        print(response.url)

                    time_taken = time.time() - s_time
                    print("Time taken: {} seconds".format(time_taken))

                    logging.info(
                        "Status: {} Headers: {}\nResponse: {}\nInput: {}\n".format(response.status_code, response.headers,
                                                                                   response.content, data))
                    print("Response: {}".format(response.content))

            elif all_fields == "N":  # Select input fields we want to fuzz.

                data = {}

                for i in inputs:
                    question = input("Would you like to fuzz field '{}' (Y/N)?: ".format(i)).upper()[
                        0]  # Check if fist later in upercase is 'Y'.
                    if question == "Y":
                        print("Please choose one of the following fuzzing methods:")
                        print("(1) Use ready made frequent XSS payloads and logg responses")
                        print("(2) Generate random data")
                        print("(3) Manualy insert data")
                        print("(4) Get one random ready made frequent XSS payloads and logg responses")
                        ans = input()

                        if ans == "1":
                            xss_fuzzing_payloads_all(serverSideFile, inputs)  # Send XSS payloads
                        elif ans == "2":
                            data[str(i)] = fuzzing_data_random()
                        elif ans == "3":
                            value = input("Insert data for {}: ".format(i))
                            data[str(i)] = value
                        elif ans == "4":
                            data[str(i)] = str(xss_fuzzing_payloads_one())

                    elif question == "N":
                        continue

                if len(data) != 0:  # Check if dictionary is empty before we try to send it
                    print("Data sent: {}".format(data))
                    if requestMethod == "POST":
                        s_time = time.time()
                        response = requests.post(serverSideFile, data=dict(data))  # headers=headers,
                        time_taken = time.time() - s_time
                    else:
                        s_time = time.time()
                        response = requests.get(serverSideFile)
                        time_taken = time.time() - s_time

                    logging.info(
                        "Status: {} Headers: {}\nResponse: {}\nInput: {}\n".format(response.status_code, response.headers,
                                                                                   response.content, data))
                    print("Time taken: {} seconds".format(time_taken))
                    print("Response: {}".format(response.content))

            flag = input("Would you like to exit?(Y/N) ").upper()[0]
            if flag == "Y":
                exit_flag = False

