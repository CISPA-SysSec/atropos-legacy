import requests
from bs4 import BeautifulSoup


def initialize_database():
    s = requests.Session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0'
    })

    r = s.get("http://127.0.0.1/xvwa/setup/?action=do")
    assert r.status_code == 200


def get_php_session_id():
    s = requests.Session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0'
    })

    s.get("http://127.0.0.1/xvwa/")
    print("PHPSESSID:", s.cookies['PHPSESSID'])


def main():
    initialize_database()
    get_php_session_id()


if __name__ == "__main__":
    main()
