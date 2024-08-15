import esprima

from yarl         import URL
from aiohttp      import ClientResponse
from bs4          import BeautifulSoup, element
from typing       import Set, List, Dict, Union, Any

from .misc        import get_logger, longest_str_match
from .types       import XSSConfidence
from .node        import Node

urlAttributes = [
    "action",
    "cite",
    "data",
    "formaction",
    "href",
    "longdesc",
    "manifest",
    "poster",
    "src"
]

class Detector():
    def __init__(self):
        self.xss_count = 0

        self._flagged_elements: Dict[XSSConfidence, Dict[str,Set[str]]] = {
            XSSConfidence.LOW : {},
            XSSConfidence.MEDIUM : {},
            XSSConfidence.HIGH : {}
        }

    @staticmethod
    def js_ast_traversal(node: Any) -> XSSConfidence:
        # TODO: manage javascript label statements
        # TODO: manage code in eval statements
        
        # print(str(type(node)))
        conf = XSSConfidence.NONE

        if type(node) == list:
            for stmt in node:
                res = Detector.js_ast_traversal(stmt)
                if res == XSSConfidence.HIGH:
                    return XSSConfidence.HIGH
                else:
                    conf = max(res, conf)

        elif 'esprima.nodes.CallExpression' in str(type(node)):
             if node.callee.name in ["alert", "prompt", "confirm"]:

                res = Detector.js_ast_traversal(node.arguments)
                if res > XSSConfidence.NONE:
                    # 0xdeadbeef found in one of its arguments
                    return XSSConfidence.HIGH
                else:
                    conf = max(res, conf)

        elif 'esprima.nodes.TaggedTemplateExpression' in str(type(node)):
            if node.quasi.type == 'TemplateLiteral' and \
               node.tag.name in ["alert", "prompt", "confirm"]:

                res = Detector.js_ast_traversal(node.quasi.quasis)
                if res > XSSConfidence.NONE:
                    # 0xdeadbeef found in one of its arguments
                    return XSSConfidence.HIGH
                else:
                    conf = max(res, conf)

        if "esprima.nodes" in str(type(node)):
            for attr in dir(node):
                res = Detector.js_ast_traversal(getattr(node, attr))
                if res == XSSConfidence.HIGH:
                    return XSSConfidence.HIGH
                else:
                    conf = max(res, conf)

        if type(node) == str:
            if longest_str_match(node, "0xdeadbeef") >= 5:
                conf = max(XSSConfidence.LOW, conf)

        return conf

    @staticmethod
    def handle_script(raw_code: str) -> XSSConfidence:
        try:
            script = esprima.parseScript(raw_code)
            return Detector.js_ast_traversal(script.body)
        except:
            # fallback to weak method
            if longest_str_match(raw_code, "0xdeadbeef") >= 5:
                return XSSConfidence.LOW
            
            return XSSConfidence.NONE

    @staticmethod
    def handle_attr(name:str, value: str) -> XSSConfidence:
        result = XSSConfidence.NONE

        if name.lower() in urlAttributes and \
           value[:11].lower() == "javascript:":
            # strip leading javascript
            value = value[11:]
            result = Detector.handle_script(value)

        elif name[:2] == "on":
            result = Detector.handle_script(value)


        return result
        
    def record_response(self, 
                        node: Node, 
                        conf: XSSConfidence, 
                        id_: str,
                        elem_type: str, 
                        value: str) -> None:
        logger = get_logger(__name__)

        if conf == XSSConfidence.NONE:
            return

        if node.url not in self._flagged_elements[conf]:
            self._flagged_elements[conf][node.url] = set()

        if id_ not in self._flagged_elements[conf][node.url]:

            if not self._flagged_elements[XSSConfidence.HIGH].get(node.url, []):
                logger.warning("Possible xss found with confidence %s. Type: %s, Value: %s, Url: %s, Node: %s",
                                conf, elem_type, value, node.full_url, node)
                if conf == XSSConfidence.HIGH:
                    self.xss_count += 1

            self._flagged_elements[conf][node.url].add(id_)

            if node.is_mutated:
                # reward parent node with a sink found
                node.parent_request.has_sinks = True

    def should_analyze(self, id_: str, url: str, content: str) -> bool:
        if id_ not in self._flagged_elements[XSSConfidence.HIGH].get(url, []) and \
            longest_str_match(content, "0xdeadbeef") >= 5:
            return True
        
        return False

    @staticmethod
    def xss_precheck(raw_html: str) -> bool:
        if longest_str_match(raw_html, "0xdeadbeef") >= 5:
            return True
        return False

    def xss_scanner(self,
                    node: Node,
                    html: BeautifulSoup) -> XSSConfidence:
        logger = get_logger(__name__)

        conf = XSSConfidence.NONE
        logger.info("Performing XSS detection...")
        
        for elem in html.find_all():
            if type(elem) != element.Tag:
                continue

            id_ = elem.name + "/" + elem.attrs.get('id', "")

            if elem.name == "script":
                if not self.should_analyze(id_, node.url, elem.text):
                    continue

                result = Detector.handle_script(elem.text)

                self.record_response(node,
                                     result, 
                                     id_, 
                                     elem_type="Script", 
                                     value=elem.text)

                conf = max(result, conf)

            for (attr_name, attr_value) in elem.attrs.items():
                param_id = id_ + "/" + attr_name

                if not self.should_analyze(param_id, node.url, attr_value):
                    continue

                result = Detector.handle_attr(attr_name, attr_value)

                self.record_response(node,
                                     result, 
                                     param_id, 
                                     elem_type=f"Attribute {attr_name}", 
                                     value=attr_value)
                conf = max(result, conf)

        node.xss_confidence = conf
        return conf
