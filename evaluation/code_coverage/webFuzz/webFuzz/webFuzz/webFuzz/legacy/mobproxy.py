from browsermobproxy import Server
from selenium import webdriver
import pathlib
import psutil
import pprint
import time
import os
import itertools

if os.name == 'nt':
    __BMP__ = str(pathlib.Path(__file__).parent.absolute()) + '\drivers\\browsermob-proxy-2.1.4\\bin\\browsermob-proxy.bat'
    __DRIVER__ = str(pathlib.Path(__file__).parent.absolute()) +'\drivers\\geckodriver.exe'
else:
    __BMP__ = str(pathlib.Path(__file__).parent.absolute()) + '/drivers/browsermob-proxy-2.1.4/bin/browsermob-proxy'
    __DRIVER__ = str(pathlib.Path(__file__).parent.absolute()) +'/drivers/geckodriver'

class ProxyManager:
    def __init__(self):
        dict = {'port': 8090}
        self.__server = Server(__BMP__, options=dict)
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

def start_proxy(url):
    for proc in psutil.process_iter():
        # check whether the process name matches
        if proc.name() == "browsermob-proxy":
            proc.kill()

    proxy = ProxyManager()
    server = proxy.start_server()
    client = proxy.start_client()
    client.new_har('req',options={'captureHeaders': True,'captureContent':True})
    print(client.proxy)

    profile = webdriver.FirefoxProfile()
    selenium_proxy = client.selenium_proxy()
    profile.set_proxy(selenium_proxy)
    driver = webdriver.Firefox(firefox_profile=profile,executable_path=__DRIVER__)
    driver.get(url)
    return (driver, client, server)

def human_interaction(url):
    driver, client, server = start_proxy(url)
    while True:
        try:
            driver.get_window_size()
        except:
            break
    pprint.pprint(client.har)
    driver.quit()
    server.stop()

    return client.har

def monkey_start(url):
    common_inputs = ['exaple@example.com', '23', '+35739747983', 'john01test', 'John Smith', '$%DFsdha(090LLl']
    driver, client, server = start_proxy(url)
    time.sleep(3)
    buttons=driver.find_elements_by_tag_name('button')
    inputs=driver.find_elements_by_tag_name('input')
    print(buttons)
    
    for common in (itertools.permutations(common_inputs, len(inputs))):
        i=0
        for inp in inputs:
            inp.clear()
            inp.send_keys(common[i])
            i+=1
            click_all_buttons(buttons)
    pprint.pprint(client.har)
    server.stop()
    driver.quit()

def click_all_buttons(buttons):
    # try clicking all the buttons.
    for button in buttons:
        try:
            button.get_
            button.click()
        except:
            pass

if __name__ == "__main__":
    # url must not be localhost, please use machine ip instead
    monkey_start("http://192.168.0.20/final/login.php")
    human_interaction("http://192.168.0.20/final/")