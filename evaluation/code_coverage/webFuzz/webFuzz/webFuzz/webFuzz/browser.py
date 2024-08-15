from __future__                 import annotations 

from urllib.parse               import urlparse
from browsermobproxy            import Server, Client
from selenium                   import webdriver
from selenium.webdriver         import Firefox, FirefoxProfile, Proxy, FirefoxOptions
from selenium.common.exceptions import WebDriverException, UnexpectedAlertPresentException
from haralyzer                  import HarParser
from pathlib                    import Path
from time                       import sleep
from typing                     import NamedTuple, Set, Dict, List, Iterator
from contextlib                 import contextmanager

import psutil

from .node                      import Node
from .types                     import HTTPMethod
from .parser                    import Parser

__BMP__ = str(Path(__file__).parent.absolute()) + '/drivers/browsermob-proxy-2.1.4/bin/browsermob-proxy'

BrowserResult = NamedTuple("BrowserResult", [("nodes", Set[Node]), ("cookies", Dict[str,str])])
ProxiedFirefox = NamedTuple("ProxiedFirefox", [("browser", Firefox), ("proxy", Client)])

class ProxyServer():
    def __init__(self, driver_loc: str = __BMP__, port: int = 8080):
        server: Server = Server(driver_loc, options={'port': port})
        self._server = server

    @staticmethod
    def killall_proxies():
        KEYWORD = 'webFuzz/drivers/browsermob-proxy-2.1.4/lib/browsermob-dist-2.1.4.jar'

        # kill all running browsermob-proxy processes
        for proc in psutil.process_iter(['cmdline']):
            if 'java' not in proc.name():
                continue

            for argument in proc.cmdline():
                if KEYWORD in argument:
                    proc.kill()
                    break

    @contextmanager
    def proxy_session(self) -> Client:
        ProxyServer.killall_proxies()
        self._server.start()

        client: Client = self._server.create_proxy(params={"trustAllServers":"true"})
        client.new_har('req', options={'captureHeaders': True,'captureContent':True})

        try:
            yield client
        finally:
            client.close()
            self._server.stop()
            ProxyServer.killall_proxies()


class Browser():
    def __init__(self, driver_loc: str, proxy_port: int = 8080):
        self._proxy = ProxyServer(port=proxy_port)
        self.driver_loc = driver_loc

    @contextmanager
    def browser(self, start_url: str) -> Iterator[ProxiedFirefox]:

        with self._proxy.proxy_session() as client:
            selenium_proxy: Proxy = client.selenium_proxy()
            profile: FirefoxProfile = FirefoxProfile()
            profile.set_proxy(selenium_proxy)

            options = FirefoxOptions()
            # allow proxing via the localhost
            options.preferences["network.proxy.allow_hijacking_localhost"] = True

            driver: Firefox = webdriver.Firefox(firefox_profile=profile, 
                                                firefox_options=options, 
                                                executable_path=self.driver_loc)
            try:
                driver.get(start_url)
                yield ProxiedFirefox(browser=driver, proxy=client)
            finally:
                driver.quit()

    
    def run_browser(self, start_node: Node) -> BrowserResult:
        cookies = {}
        nodes: Set[Node] = set()

        with self.browser(start_node.full_url) as pf:
            while True:
                sleep(1)

                try:
                    cookies = pf.browser.get_cookies()
                except UnexpectedAlertPresentException:
                    pass
                except WebDriverException:
                    nodes = Browser.parse_har_file(start_node, pf.proxy.har)
                    break


        cookies = {c['name']: c['value'] for c in cookies}
        return BrowserResult(nodes, cookies)

    @staticmethod
    def parse_har_file(start_node: Node, har_file: dict) -> Set[Node]:
        har_parser = HarParser(har_file)
        data = har_parser.har_data['entries']

        nodes = set()

        for entry in data:
            url_obj = urlparse(entry['request']['url'])

            if not Parser.is_same_domain(url_obj, start_node.url_object):
                continue

            try:
                method = HTTPMethod[entry['request'].get('method', 'GET').upper()]
            except:
                # HTTP method not supported
                continue

            post_params: Dict[str, List[str]] = {}
            
            if method == HTTPMethod.POST:
                raw_params: List[Dict[str, str]] = entry['request'].get('postData', {}).get('params', [])
                post_params = { str(kv["name"]) : [ str(kv["value"]) ] for kv in raw_params }

            nodes.add(Node(url_obj, method, { HTTPMethod.GET: {}, HTTPMethod.POST: post_params}))

        return nodes

def browser_test():
    __DRIVER__ = str(Path(__file__).parent.absolute()) + '/drivers/geckodriver'

    b = Browser(__DRIVER__, proxy_port=8090)

    print(b.run_browser(Node("http://localhost/admin/index.php", HTTPMethod.GET)))
