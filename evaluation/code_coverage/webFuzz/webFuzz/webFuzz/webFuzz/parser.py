from urllib.parse import urlparse, urlunparse, urljoin
from bs4          import BeautifulSoup
from typing       import Set, List, Dict

from .misc        import get_logger, query_to_dict
from .types       import HTTPMethod, UrlType
from .node        import Node


class Parser:
    @staticmethod
    def parse(node: Node, soup: BeautifulSoup) -> Set[Node]:
        form_links = Parser.parse_forms(soup, node)
        a_links = Parser.parse_anchors(soup, node)

        return a_links | form_links

    @staticmethod
    def parse_anchors(html: BeautifulSoup, called_node: Node) -> Set[Node]:
        """
        Extract href links and their parameters.
        """
        logger = get_logger(__name__)
        logger.debug("==> Extracting <a> links from html")

        links: Set[Node] = set()

        for anchor in html.findAll('a'):  # Search for all anchor elements.
            logger.debug("==> link parsing: %s", anchor)

            url_obj = urlparse(anchor.get('href') or "")

            if not Parser.is_same_domain(url_obj, called_node.url_object):
                continue

            url_obj = Parser.normalise_url(called_node.url_object, url_obj)

            links.add(Node(url=url_obj,
                           method=HTTPMethod.GET))

        logger.debug("==> got new links: %s", links)
        return links

    @staticmethod
    def parse_forms(html: BeautifulSoup, called_node: Node) -> Set[Node]:
        """
        Extract action, method and input fields from HTML forms.
        """
        logger = get_logger(__name__)
        logger.debug("==> Extracting data from forms")

        links: Set[Node] = set()  # A set that contains all links found in the forms.

        for form in html.findAll('form'):
            logger.debug("==> Form parsing: %s", form)

            url_obj = urlparse(form.get('action') or "")

            if not Parser.is_same_domain(url_obj, called_node.url_object):
                continue

            url_obj = Parser.normalise_url(called_node.url_object, url_obj)

            get_params = query_to_dict(url_obj.query)

            # Convert the url object back to string but without the query.
            url: str = urlunparse(url_obj._replace(query=''))

            # Extract post/get parameters from select, input, or textarea html elements
            selects: Dict[str, List[str]]   = Parser.parse_input_like(form.findAll('select'))
            inputs: Dict[str, List[str]]    = Parser.parse_input_like(form.findAll('input'))
            textareas: Dict[str, List[str]] = Parser.parse_input_like(form.findAll('textarea'))

            body_params = {}
            body_params.update(selects)
            body_params.update(inputs)
            body_params.update(textareas)

            # Method extraction from form.
            method = HTTPMethod[form.get('method', 'GET').upper()]
            if method == HTTPMethod.GET:
                get_params.update(body_params)
                body_params = {}

            logger.debug("==> Form get: %s", get_params)
            logger.debug("==> Form body: %s", body_params)

            links.add(Node(url=url,
                           method=method,
                           params={HTTPMethod.GET: get_params, HTTPMethod.POST: body_params}))

        logger.debug("==> Got new links: %s", links)
        return links

    @staticmethod
    def parse_input_like(inputs: List) -> Dict[str, List[str]]:
        result: Dict[str, List[str]] = {}

        for html_input in inputs:

            name: str = html_input.get('name', '')
            if not name:
                continue

            value: str = html_input.get('value', '')
            if not value:
                # if no value present, search in child <option> elements
                option = html_input.find('option')
                if option:
                    value: str = option.get('value', '')

            if name in result:
                result[name].append(value)
            else:
                result[name] = [value]

        return result

    @staticmethod
    def is_same_domain(url1: UrlType, url2: UrlType) -> int:
        if not url1.netloc or not url2.netloc:
            # if one link has not domain
            # then its domain is determined by the
            # other link
            return True 
        if url1.netloc == url2.netloc:
            return True
        return False

    @staticmethod
    def relative_to_absolute(base_url:UrlType, relative_url:UrlType) -> UrlType:
        """
        Converts a relative url to an absolute.
        e.g. href="action.php" called from http://localhost/api/login.php
        should be: http://localhost/api/action.php
        """
        if not base_url.path:
            # base url points to the root directory
            prefix = "/"
        else:
            prefix = base_url.path[0:base_url.path.rfind("/")] + "/" 
        
        return relative_url._replace(path=urljoin(prefix, relative_url.path))
        #return relative_url._replace(path=urljoin(base_url.geturl(), relative_url.path))

    @staticmethod
    def set_default_query(base_url:UrlType, target_url: UrlType) -> UrlType:
        """
        Replace query field of url_obj with the query string of the self.node.
        Essentially it returns the same address of self.node).
        """
        return target_url._replace(query=base_url.query)

    @staticmethod
    def set_default_path(base_url:UrlType, target_url: UrlType) -> UrlType:
        """
        Replace url_obj path with the path of calling node.
        """
        return target_url._replace(path=base_url.path)

    @staticmethod
    def set_default_domain(base_url: UrlType, target_url: UrlType) -> UrlType:
        """
        Set the netloc and scheme of target_url as that of base_url
        """
        return target_url._replace(scheme=base_url.scheme, netloc=base_url.netloc)

    @staticmethod
    def normalise_url(called_url: UrlType, target_url: UrlType) -> UrlType:
        """
        Fixes a URL object as returned from urllib.parse.urlparse.
        It will try to turn it to an absolute url.
        """
        
        if target_url.netloc:
            # Link has a domain name
            # thus it is absolute
            return target_url

        if target_url.path and target_url.path[0] != "/":
            # path is relative
            target_url = Parser.relative_to_absolute(called_url, target_url)

        elif not target_url.path:
            # Link points to the same URL the request was made.
            # Fix path to point to that.
            # e.g. href="#", href="", href="?hey=there"

            target_url = Parser.set_default_path(called_url, target_url)

            if not target_url.query:
                target_url = Parser.set_default_query(called_url, target_url)

        target_url = Parser.set_default_domain(called_url, target_url)

        return target_url
