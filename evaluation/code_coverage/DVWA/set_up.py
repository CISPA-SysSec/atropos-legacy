import requests
from bs4 import BeautifulSoup


def get_user_token(s):
    assert s.status_code == 200
    soup = BeautifulSoup(s.text, "html.parser")
    user_token = soup.find_all("input", {"name": "user_token"})
    assert len(user_token) == 1
    return user_token[0]["value"]


def initialize_database():
    s = requests.Session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0'
    })

    token = get_user_token(s.get("http://localhost/login.php"))

    r = s.post("http://localhost/login.php", data={
            "username": "admin",
            "password": "password",
            "user_token": token,
            "Login": "Login",
        },
    )
    assert r.status_code == 200

    token = get_user_token(s.get("http://localhost/setup.php"))
    r = s.post("http://localhost/setup.php", data={
            "create_db": "Create / Reset Database",
            "user_token": token,
        },
    )
    assert r.status_code == 200


def get_php_session_id():
    s = requests.Session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0'
    })

    s.get("http://localhost/login.php")
    print("PHPSESSID:", s.cookies['PHPSESSID'])


def main():
    initialize_database()
    get_php_session_id()


if __name__ == "__main__":
    main()
