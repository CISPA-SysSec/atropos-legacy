#!/usr/bin/python

import sys, random, itertools
from bs4 import BeautifulSoup
import html5lib
from urllib.parse import urlparse, urlunparse, urljoin, parse_qs
from typing       import Set, List, Dict
from hashable_bytearray import *
from icecream import ic

# turn "abc.php?def=ghi&jkl=mno" to [("def", "ghi"), ("jkl", "mno")]
def url_extract_inputs(url):
    _inputs = []
    try:
        path = urlparse(url).path
        query = urlparse(url).query
        for (x, y0) in parse_qs(query).items():
            for y in y0:
                _inputs.append((x,y))
        # sometimes the URL does not contain parsable data but it's a mod_rewrite directive
        # in which case extract it as a REQUEST_URI variable
        if len(path) > 0 and not path.endswith(".php"):
            request_uri = urlparse(url)._replace(netloc="")._replace(scheme="").geturl()
            _inputs.append(("REQUEST_URI", request_uri))
        return _inputs
    except:
        return _inputs

# URLs can be weird, absolute, relative etc., make sure they are transformed to php filenames when possible
def transform_url_to_filename(url):
    new_path = relative_url_to_absolute_path(url)
    if new_path.endswith("/"):
        new_path += "index.php"
    return new_path

# relative paths like "1/2/../bla/" will be turned to "1/bla/", which is necessary for some links
def relative_url_to_absolute_path(url):
    # trick: urljoin can parse relative paths, so construct a new url and then just extract the path
    try:
        p = urljoin("http://localhost/", urlparse(url).path)
        return urlparse(p).path
    except:
        return url

def html_extract_inputs(html):
    inputs = []
    # every target can have GET or POST variables
    # so for every link we extract GET information
    # and every form we extract POST information
    # it's important to remember the association between a php file and it's inputs
    try:
        b = BeautifulSoup(html, "html5lib")
    except:
        return inputs

    # first, extract all GET data for link references
    for a in b.findAll("a"):
        url = a.get("href", "")
        inputs.append((transform_url_to_filename(url), url_extract_inputs(url)))
    
    # now extract all POST data from form elements
    for form in b.findAll('form'):
        url = form.get("action", "")
        url_inputs = url_extract_inputs(url)
        for html_tag in ["select", "textarea", "input"]:
            elements = form.findAll(html_tag)
            inps = extract_form_inputs(elements)
            inps.extend(url_inputs)
            inputs.append((transform_url_to_filename(url), inps))
        
    return inputs

def html_inputs_to_hb(inputs):
    _inputs = []
    for (filename, inps) in inputs:
        filename_hb = HashableBytearray(filename.encode())
        inputs_hb = []
        for (key, value) in inps:
            inputs_hb.append((HashableBytearray(key.encode()), HashableBytearray(value.encode())))
        _inputs.append((filename_hb, inputs_hb))
    return _inputs

def extract_form_inputs(elements):
    m = []
    for element in elements:
        name = element.get('name', '')
        if not name:
            name = element.get('id', '')
            if not name:
                continue
        value = element.get('value', '')
        if not value:
            options = element.findAll('option')
            if options:
                # if there are multiple options to choose from, make random choice
                #option = random.choice(options)
                for option in options:
                    value = option.get('value', '')
                    m.append((name, value))
            else:
                m.append((name, value))
        else:
            m.append((name, value))

    return m

if __name__ == "__main__":
    print(transform_url_to_filename(""))
    print(url_extract_inputs("/bla/?test=a&bla[a]=blubb"))
    print(html_inputs_to_hb(html_extract_inputs(open(sys.argv[1], "r").read())))
