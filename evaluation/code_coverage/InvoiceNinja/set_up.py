import requests
from bs4 import BeautifulSoup


def get_csrf_token(s):
    assert s.status_code == 200
    soup = BeautifulSoup(s.text, "html.parser")
    user_token = soup.find_all("meta", {"name": "csrf-token"})
    assert len(user_token) == 1
    return user_token[0]["content"]


def set_up():
    s = requests.Session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0'
    })

    r = s.get("http://localhost/setup")
    assert r.status_code == 200
    csrf_token = get_csrf_token(r)

    try:
        r = s.post("http://localhost/setup", data={
            "_token": csrf_token,
            "url": "http://localhost",
            "db_driver": "MySQL",
            "db_host": "127.0.0.1",
            "db_port": "3306",
            "db_database": "db-ninja-01",
            "db_username": "ninja",
            "db_password": "ninja",
            "mail_driver": "log",
            "mail_name": "",
            "mail_address": "",
            "mail_username": "",
            "mail_host": "",
            "mail_port": "",
            "encryption": "tls",
            "mail_password": "",
            "first_name": "Ant",
            "last_name": "Tropos",
            "email": "ant@tropos.com",
            "password": "pass",
            "terms_of_service": "on",
            "privacy_policy": "on",
        })
    except requests.exceptions.ConnectionError as e:
        print(f"(This is fine) Expected ConnectionError: {e}")


def main():
    set_up()


if __name__ == "__main__":
    main()
