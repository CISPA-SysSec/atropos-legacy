import unittest
from unittest.mock import Mock
from os.path import dirname
import webFuzz.parser as parser
from webFuzz.node import Node, Http_method
from webFuzz.environment import env
from urllib.parse import urlparse, urlunparse, urlencode
import asyncio


# TODO: Simplify this test suite


# to run this test do
# cd 'web_fuzzer' and run: python -m unittest tests.test_parser -v

class TestParserMethods(unittest.TestCase):
    def setUp(self):
        # base_url and xss corpus
        self.parser = parser.Parser("http://localhost/wp-admin/index.php",
                                    ["<script>alert(121234)</script>", "<body onload=alert(121234)>"])

        self.test_node = Node(url="http://localhost/wp-admin/admin-ajax.php",
                              method=Http_method.GET,
                              params={Http_method.GET: {'s': "21213vreg<body onload=alert(121234)>234dfw"},
                                      Http_method.POST: {}},
                              cover_score_parent=0,
                              xss_params={Http_method.GET: set([('s', 1), ('tib', 0)]),
                                          Http_method.POST: set()})

        # methods that test Parser.parse_url need this
        self.parser.node = self.test_node

        # create Mock object of type aiohttp.ClientResponse
        f = open(dirname(__file__) + "/test_html.html", "r")
        html = f.read()
        f.close()

        async def returnCoMock():
            return html

        self.req = Mock()
        self.req.text = returnCoMock
        self.req.request_info.real_url = "http://localhost/wp-admin/admin-ajax.php"

        margs = Mock()
        margs.anchor_unique = False
        env.args = margs

        mtrace = Mock()
        mtrace.return_value = None
        parser.logging.Logger.trace = mtrace

    def test_valid_parsing_url(self):
        x = self.parser.parse_url(urlparse("http://localhost/"))
        self.assertTrue(urlunparse(x) == "http://localhost/")

    def test_relative_parsing_url(self):
        x = self.parser.parse_url(urlparse("logout.php"))
        self.assertTrue(urlunparse(x) == "http://localhost/wp-admin/logout.php")

    def test_empty_parsing_url(self):
        self_req = urlparse(self.test_node.get_url())
        self_req = self_req._replace(query=urlencode(self.test_node.get_params()[Http_method.GET], doseq=True))

        x = self.parser.parse_url(urlparse("#"))

        self.assertTrue(urlunparse(x) == urlunparse(self_req))

        x = self.parser.parse_url(urlparse(""))
        self.assertTrue(urlunparse(x) == urlunparse(self_req))

        x = self.parser.parse_url(urlparse("?"))
        self.assertTrue(urlunparse(x) == urlunparse(self_req))

    def test_query_only_url(self):
        self_req = urlparse(self.test_node.get_url())
        self_req = self_req._replace(query="hey=there")

        x = self.parser.parse_url(urlparse("?hey=there"))
        self.assertTrue(urlunparse(x) == urlunparse(self_req))

    def test_empty_domain_parsing_url(self):
        x = self.parser.parse_url(urlparse("/action/logout.php"))
        self.assertTrue(urlunparse(x) == "http://localhost/action/logout.php")

    def test_different_domain_parsing_url(self):
        x = self.parser.parse_url(urlparse("http://mydomain/wp-admin/logout.php"))
        self.assertTrue(isinstance(x, type(None)))

    def test_different_port_parsing_url(self):
        x = self.parser.parse_url(urlparse("http://localhost:8989/action/logout.php"))
        self.assertTrue(isinstance(x, type(None)))

    def test_parser(self):
        # before calling parse_a_links() and parse_forms(),
        # parse() needs to be called first to set up the object
        # attributes first (self.soup, self.req, ...)
        asyncio.run(self.async_test_parser())

    async def async_test_parser(self):
        with self.assertLogs(logger="webFuzz.parser", level='WARNING') as _:
            actual_nodes = await self.parser.parse(self.req, self.parser.node)

            expected_nodes = [
                Node(url="http://localhost/wp-admin/admin.php",
                     method=Http_method.GET,
                     params={Http_method.GET: {'page': ['mailpoet-newsletter-editor'],
                                               'id': ['1</script><script>alert("hello");</script>']},
                             Http_method.POST: {}},
                     cover_score_parent=0),
                Node(url="http://localhost/wp-admin/admin.php",
                     method=Http_method.GET,
                     params={Http_method.GET: {'page': ['ninja-forms'],
                                               'success': ["'</script><script>alert(123);</script>"]},
                             Http_method.POST: {}},
                     cover_score_parent=0),
                Node(url="http://localhost/index.php",
                     method=Http_method.GET,
                     params={Http_method.GET: {'p': ['1745'], 'Display_FAQ': ['</script><svg/onload=alert(/XSS/)>']},
                             Http_method.POST: {}},
                     cover_score_parent=0),
                Node(url="http://localhost/wp-admin/root-ajax.php",
                     method=Http_method.POST,
                     params={Http_method.GET: {},
                             Http_method.POST: {
                                 'action': ['nf_ajax_submit'],
                                 'formData': [
                                     '{"id":"1", "fields": { "1": { "value" : "<body onload=alert(document.cookie)>", "id": 1}}}']
                             }},
                     cover_score_parent=0),
                Node(url="http://localhost/wp-admin/user-ajax.php",
                     method=Http_method.POST,
                     params={Http_method.GET: {},
                             Http_method.POST: {
                                 'answer': ["x ", ""],
                                 'question_type': [""],
                                 'points': ['0', '1', '2'],
                                 'action': ['chainedquiz_ajax'],
                                 'chainedquiz_action': ['answer'],
                                 'total_questions': ['1v4918<script>alert(document.cookie)</script>eyjfw']
                             }},
                     cover_score_parent=0),
                Node(url="http://localhost/wp-admin/admin-ajax.php",
                     method=Http_method.GET,
                     params={Http_method.GET: {'test': ["default"]},
                             Http_method.POST: {}},
                     cover_score_parent=0),
            ]

            for n in actual_nodes:
                self.assertIn(n, expected_nodes)

    def test_look_for_xss(self):
        asyncio.run(self.async_test_look_for_xss())

    async def async_test_look_for_xss(self):
        # should only return one possible rxss. xss in 'tib' parameter is htmlencoded in test_html.html
        with self.assertLogs(logger="webFuzz.parser", level='WARNING') as cm:
            await self.parser.parse(self.req, self.parser.node)
            self.assertEqual(len(cm.output), 1)
            self.assertIn(
                "WARNING:webFuzz.parser:Possible xss found in key s. Url: http://localhost/wp-admin/admin-ajax.php",
                cm.output[0])


if __name__ == '__main__':
    unittest.main()
