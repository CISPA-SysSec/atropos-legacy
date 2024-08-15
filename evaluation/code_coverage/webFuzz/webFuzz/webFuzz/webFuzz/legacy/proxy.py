from browsermobproxy import Server
from selenium import webdriver
from haralyzer import HarParser, HarPage
import json
import pathlib
import psutil
import pprint
import time
import os
import itertools
import warnings
warnings.filterwarnings("ignore")

__BMP__ = str(pathlib.Path(__file__).parent.absolute()) + '/drivers/browsermob-proxy-2.1.4/bin/browsermob-proxy'
__DRIVER__ = str(pathlib.Path(__file__).parent.absolute()) +'/drivers/geckodriver'

class ProxyManager:
    def __init__(self):
        self.__server = Server(__BMP__, options={'port': 8090})
        self.__clinet = None

    def start_server(self):
        self.__server.start()
        return self.__server
    
    def start_client(self):
        self.__client=self.__server.create_proxy(params={"trustAllServers":"true"})
        return self.__client

    @property
    def client(self):
        return self.__client
    @property
    def server(self):
        return self.__server

def start_proxy(url, driver_loc):
    for proc in psutil.process_iter():
        # check whether the process name matches
        if proc.name() == "browsermob-proxy":
            proc.kill()

    proxy = ProxyManager()
    server = proxy.start_server()
    client = proxy.start_client()
    client.new_har('req',options={'captureHeaders': True,'captureContent':True})

    profile = webdriver.FirefoxProfile()
    selenium_proxy = client.selenium_proxy()
    profile.set_proxy(selenium_proxy)
    driver = webdriver.Firefox(firefox_profile=profile,executable_path=driver_loc)
    driver.get(url)
    return (driver, client, server)

def parse_response(url, har_file):
    har_parser = HarParser(har_file)
    data=har_parser.har_data['entries']
    
    parsed = []

    for d in data:
       if url in d['request']['url']:
          current=[d['request']['url'], d['request']['method']]
          if d['request']['method'] == 'POST':
            current.append(d['request']['postData'])
          parsed.append(current)
           
           
    return parsed

def run(start_url: str, driver_loc: str):
    driver, client, server = start_proxy(start_url, driver_loc)
    while True:
        try:
            driver.get_window_size()
        except:
            break
    driver.quit()
    server.stop()

    return parse_response(start_url, client.har)


if __name__ == "__main__":

    # url must not be localhost, please use machine ip instead
    response=run("http://192.168.0.111:8888/", __DRIVER__)
    print(response)