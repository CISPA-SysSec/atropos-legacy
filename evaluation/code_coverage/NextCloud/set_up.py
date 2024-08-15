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

    r = s.get("http://localhost/index.php")
    assert r.status_code == 200

    # r = get_user_token(s.get("http://localhost/login.php"))

    r = s.post("http://localhost/index.php", data={
            "install": "true",
            "adminlogin": "next",
            "adminpass": "cloud",
            "adminpass-clone": "cloud",
            "directory": "/var/www/html/data",
            "dbtype": "mysql",
            "dbuser": "nextcloud",
            "dbpass": "secure",
            "dbpass-clone": "secure",
            "dbname": "nextcloud",
            "dbhost": "127.0.0.1",
        },
    )
    assert r.status_code == 200


# curl 'http://localhost:3456/ocs/v2.php/cloud/users' --compressed -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0' -H 'Accept: application/json, text/plain, */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/json;charset=utf-8' -H 'requesttoken: 76tN+yYjdRoREDD2VJHXq0TwJA65a+MJ0W1J72BBBPk=:ut4ktGtxPEBkdgevJr68+yPFcn3JIbdIhTQdowtzUsw=' -H 'Origin: http://localhost:3456' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'DNT: 1' -H 'Sec-GPC: 1' -H 'Connection: keep-alive' -H 'Cookie: phpwcmsBELang=en; PHPSESSID=296b9e83209133175bf462749ce34963; ninja_session=eyJpdiI6Ik9TbFE4Z2I4amFyQmFmMmdBYjZid3c9PSIsInZhbHVlIjoiTHdcL1ljMmhUR3JiVldEcm96QmcyRHVJeUdCV0JsRFlUWG9mVVZ6Sk5FZXpHYis2UWozYVJOcUhMRkxyeVJCdDZUM05HM2t2VWZVelRHSzVPaGE4V0RXbU9vT0tFeEQweDRPZ29aXC9WSkUxbHhuTlNGbWI3VmRyVGNYbDk4RXJ2MCIsIm1hYyI6ImNiNWM5MDhiYzJhYjE3NDY0ZTk5MTk3NThlOTViZmJiMGNiYmM0NTEyNDcxZWFhNzhjMDQ3MjM5NWRiMjk1YzgifQ%3D%3D; occalftq3eue=d5c310d32b807d220339f8ad909f20f7; oc_sessionPassphrase=IvhgzJBd4RPDWG8fTaAK8PqlJAiHj2Cn%2Br7rHgni%2FzQmEYDPFfT28jcyFXmexnZmnWuCqA%2BT%2B7B5OIuahn2p7pZ0EbD82aXxHZFKwSljpKHgX%2BMXi7yv5IrIUrv%2B0L%2FT; ocufgl2thtdq=09877c8e76bab8b84b5c441cf1d6f5d1; nc_sameSiteCookielax=true; nc_sameSiteCookiestrict=true; nc_username=next; nc_token=hSFd6Cky8ei3IA0pbT8vAtxLo5fOEGB6; nc_session_id=09877c8e76bab8b84b5c441cf1d6f5d1' --data-raw '{"userid":"user1","password":"securestuff","displayName":"user","email":"","groups":[],"subadmin":[],"quota":"default","language":"en"}'


def main():
    initialize_database()


if __name__ == "__main__":
    main()
