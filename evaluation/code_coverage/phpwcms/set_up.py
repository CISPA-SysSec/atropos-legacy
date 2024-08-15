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

    r = s.get("http://localhost:80/phpwcms/setup/")
    assert r.status_code == 200

    r = s.post("http://localhost:80/phpwcms/setup/setup.php?step=3", data={
        "db_host": "127.0.0.1",
        "db_user": "phpwcms",
        "db_pass": "passw0rd",
        "db_table": "phpwcms",
        "db_prepend": "",
        "db_pers": "1",
        "charset": "en-utf-8",
        "collation": "utf8_general_ci",
        "db_sql_hidden": "1",
        "admin_name": "Webmaster",
        "admin_user": "admin",
        "admin_pass": "admin_pass",
        "admin_passrepeat": "",
        "admin_email": "noreply@localhost:8080",
        "dbsavesubmit": "Continue",
        "do": "1",
    })


    print(r.text)
    assert r.status_code == 200


def get_php_session_id():
    s = requests.Session()
    s.headers.update({
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0'
    })

    s.get("http://127.0.0.1/phpwcms/")
    print("PHPSESSID:", s.cookies['PHPSESSID'])


def main():
    initialize_database()
    # get_php_session_id()


if __name__ == "__main__":
    main()

# curl 'http://localhost:8080/phpwcms/setup/setup.php' --compressed -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost:8080' -H 'Connection: keep-alive' -H 'Referer: http://localhost:8080/phpwcms/setup/index.php' -H 'Cookie: security=impossible; PHPSESSID=ab22847ab18a4b31a3c7106c7370ec93' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'DNT: 1' -H 'Sec-GPC: 1' --data-raw 'Submit=I+agree+the+GPL%2C+continue%E2%80%A6'


# curl 'http://localhost:8080/phpwcms/setup/setup.php?step=1' --compressed -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost:8080' -H 'Connection: keep-alive' -H 'Referer: http://localhost:8080/phpwcms/setup/setup.php' -H 'Cookie: security=impossible; PHPSESSID=ab22847ab18a4b31a3c7106c7370ec93' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'DNT: 1' -H 'Sec-GPC: 1' --data-raw 'Submit=Start+setup+of+phpwcms'


# curl 'http://localhost:8080/phpwcms/setup/setup.php?step=1' --compressed -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/114.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://localhost:8080' -H 'Connection: keep-alive' -H 'Referer: http://localhost:8080/phpwcms/setup/setup.php?step=1' -H 'Cookie: security=impossible; PHPSESSID=ab22847ab18a4b31a3c7106c7370ec93' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'DNT: 1' -H 'Sec-GPC: 1' --data-raw 'db_host=127.0.0.1&db_user=phpwcms&db_pass=passw0rd&db_table=phpwcms&db_prepend=&db_pers=1&dbsavesubmit=Continue&do=1'


# http://localhost:8080/phpwcms/setup/setup.php?step=1

# step=1

# db_host=127.0.0.1
# db_user=phpwcms
# db_pass=passw0rd
# db_table=phpwcms
# db_prepend
# db_pers=1
# charset=en-utf-8
# collation=utf8_general_ci
# dbsavesubmit=Continue
# do=1



# http://localhost:8080/phpwcms/setup/setup.php?step=1

# step=1

# db_host=127.0.0.1
# db_user=phpwcms
# db_pass=passw0rd
# db_table=phpwcms
# db_prepend
# db_pers=1
# charset=en-utf-8
# collation=utf8_general_ci
# db_sql=1
# db_sql_hidden=1
# db_create=1
# dbsavesubmit=Continue
# do=1






# http://localhost:8080/phpwcms/setup/setup.php?step=2

# step=2

# site
# smtp_from_email=info@localhost
# smtp_from_name=My Name
# smtp_host=localhost
# smtp_port=25
# smtp_mailer=mail
# smtp_user=user
# smtp_pass=pass
# smtp_secure
# Submit=send site data
# do=1



# http://localhost:8080/phpwcms/setup/setup.php?step=3

# doc_root=/var/www/html
# root=phpwcms
# file_path=filearchive
# templates=template
# ftp_path=upload
# Submit=send path values
# do=1