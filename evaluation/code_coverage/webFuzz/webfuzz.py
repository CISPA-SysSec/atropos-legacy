#!/usr/bin/python3
import os
from bs4 import BeautifulSoup
import argparse
import shlex
import requests
from urllib.parse import urljoin, urlparse
import re
import time
import base64
import json

SESSION_TAMPERING_FILES = ["logout.php", "ba_logout_1.php", "install.php", "setup.php", "login.php"]

def print_red(t): 
    print(f"\033[91m {t}\033[00m")

def fetch_html_content(url):
    # Send HTTP request to the URL
    response = requests.get(url)
    
    # Check if the request was successful
    if response.status_code == 200:
        # Parse the HTML content
        soup = BeautifulSoup(response.text, 'html.parser')
        return soup.prettify()  # Returns the HTML content as a string
    else:
        raise Exception(f"Failed to retrieve the webpage. HTTP Status Code: {response.status_code}")

def parse_arguments(command_line):
    parser = argparse.ArgumentParser(description="Parse form data")
    parser.add_argument("--form-user", help="User for the form")
    parser.add_argument("--form-password", help="Password for the form")
    parser.add_argument("--form-url", help="URL for the form")
    
    # Use shlex to split the command_line string into a list of arguments similar to sys.argv
    args, _ = parser.parse_known_args(shlex.split(command_line))
    
    return args.form_user, args.form_password, args.form_url

def find_login_field_ids(html, base_url):
    soup = BeautifulSoup(html, 'html.parser')
    
    username_field = None
    password_field = None
    submit_button = None
    target_url = None
    
    parsed_base_url = urlparse(base_url)
    base_path = parsed_base_url.path.rsplit('/', 1)[0]
    base_url_with_path = f"{parsed_base_url.scheme}://{parsed_base_url.netloc}{base_path}/"

    # Search through all form tags in the HTML
    for form_tag in soup.find_all('form'):
        
        # Look for input tags with type="text" within the form tag for possible username field
        for input_tag in form_tag.find_all('input', {'type': 'text'}):
            username_field = input_tag.get('id', None) if input_tag.get('id', None) else input_tag.get('name', None)
            if username_field:
                break
        
        # Look for input tags with type="password" within the form tag for password field
        if username_field:
            for input_tag in form_tag.find_all('input', {'type': 'password'}):
                password_field = input_tag.get('id', None) if input_tag.get('id', None) else input_tag.get('name', None)
                if password_field:
                    break
        
        # Look for input or button tags with type="submit" within the form tag for submit button
        if username_field and password_field:
            for input_tag in form_tag.find_all(['input', 'button'], {'type': 'submit'}):
                submit_button = input_tag.get('id', None) if input_tag.get('id', None) else input_tag.get('name', None)
                if submit_button:
                    break
            
            # Extract the action attribute, which specifies the target URL
            action = form_tag.get('action', None)
            
            if not action:  # If action is missing, assume current URL
                target_url = base_url
            else:  # Combine with base URL, taking into account relative paths
                target_url = urljoin(base_url_with_path, action)
            
            return username_field, password_field, submit_button, target_url

    return username_field, password_field, submit_button, target_url

def login_and_get_cookies(login_url, payload):
    # Initialize an HTTP session to keep cookies between requests
    session = requests.Session()
    
    # Perform login
    response = session.post(login_url, data=payload)
    
    # Check if the login was successful (this can vary depending on how the website handles logins)
    if response.status_code == 200:
        # Extract cookies into a key=value map
        cookies_dict = {}
        for cookie in session.cookies:
            cookies_dict[cookie.name] = cookie.value
        
        return cookies_dict
    else:
        return f"Login failed. HTTP Status Code: {response.status_code}"

def list_all_files(directory):
    file_list = []
    for root, dirs, files in os.walk(directory):
        for f in files:
            abs_path = os.path.abspath(os.path.join(root, f))
            file_list.append(abs_path)
    return file_list

def delete_logout_files():
    all_files = list_all_files("/var/www/")
    okay_files = []
    for f in all_files:
        # does this look like a sensitive file?
        if any(t for t in SESSION_TAMPERING_FILES if f.endswith(t)):
            os.remove(f)
        else:
            okay_files.append(f)
    return set(all_files) - set(okay_files)

def extract_php_strings_from_files(file_paths):
    extracted_strings = []
    
    # This regular expression pattern captures string literals enclosed in single 
    # quotes or double quotes but ignores escape sequences.
    string_pattern = r'"[^"]*"|\'[^\']*\''
    
    for file_path in file_paths:
        try:
            if not file_path.lower().endswith('.php'):
                continue  # Skip non-PHP files

            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                strings_in_file = re.findall(string_pattern, content)
                extracted_strings.extend(strings_in_file)
        except Exception as e:
            print(f"Could not read {file_path}: {e}")

    # Remove the enclosing quotes from the captured strings.
    extracted_strings = [s[1:-1] for s in extracted_strings]
    
    return extracted_strings

def extract_xml_value(xml, tag):
    pattern = rf'<{tag}>(.*?)<\/{tag}>'
    match = re.search(pattern, xml)
    if match:
        return match.group(1)
    else:
        return None

def extract_wapiti_config():
    with open("/wapiti_context/args", "r") as f:
        user, password, login_url = parse_arguments(f.read())

    print(user, password, login_url)
    if user and password and login_url:
        html_content = fetch_html_content(login_url)
        username_field, password_field, submit_button_field, login_url = find_login_field_ids(html_content, login_url)
        if username_field is None or password_field is None:
            raise Exception(f"username_field ({username_field}) or password_field ({password_field}) for {login_url} could not be extracted:{html_content}\n")
        else:
            if not submit_button_field:
                submit_button_field = "submit"
            return (login_url, {username_field: user, password_field: password, submit_button_field: ""})
    else:
        raise Exception("Could not extract user, password or login_url from Wapiti config")

def extract_zap_config():
    ZAP_CONTEXT_FILE = "/zap_context/ZAP.context"
    if os.path.isfile(ZAP_CONTEXT_FILE):
        with open(ZAP_CONTEXT_FILE, "r") as f:
            zap_context = f.read()
            xml_loginbody = extract_xml_value(zap_context, "loginbody")
            xml_loginurl = extract_xml_value(zap_context, "loginurl")
            xml_user = extract_xml_value(zap_context, "user")
            if xml_loginbody and xml_loginurl:
                if "{%" in xml_loginbody:
                    if xml_user:
                        user_data = xml_user.split(";")
                        (username, password, *_) = user_data[4].split("~")
                        username = base64.b64decode(username).decode()
                        password = base64.b64decode(password).decode()
                        xml_loginbody = xml_loginbody.replace("{%username%}", username)
                        xml_loginbody = xml_loginbody.replace("{%password%}", password)
                    else:
                        raise Exception("Couldn't extract user login data")
                payload = {s.split("=")[0]: s.split("=")[1] for s in xml_loginbody.split("&amp;")}
                print(payload)
                return (xml_loginurl, payload)
            else:
                raise Exception("Couldn't find login data or target URL in ZAP.context")

print("Wfuzz.py wrapper starting...")

try:
    print("Trying to extract login data via ZAP.context")
    (login_url, payload) = extract_zap_config()
    with_login = True
except Exception as e:
    try:
        print(str(e))
        print("Trying alternative method via Wapiti")
        (login_url, payload) = extract_wapiti_config()
        with_login = True
    except Exception as e:
        print(str(e))
        print_red("[!] No login method works, trying without...")
        with_login = False
        time.sleep(5)

cookies = {}
if with_login:
    print("Trying to login via these data:")
    print(login_url, payload)
    cookies = login_and_get_cookies(login_url, payload)
    print("Cookies after login:", cookies)
    wfuzz_cookie_arg = '&'.join([f"{key}={value}" for key,value in cookies.items()])

print(cookies)
with open("/dev/shm/session.json", "w+") as f:
    json.dump(cookies, f)

deleted_files = delete_logout_files()
print(f"Deleted session tampering files: {deleted_files}")

w = f"cd /var/www/webfuzz-fuzzer/webFuzz/; SESSION=/dev/shm/session.json timeout -k 10 {24*60*60}  python3 webFuzz.py --ignore_4xx -w 8 --meta /var/www/html/instr.meta --driver webFuzz/drivers/geckodriver -vv --request_timeout 100 -s -r simple http://localhost/list_php_files.php"
print(w)
os.system(w)

# url = 'http://localhost/list_php_files.php'
# reqs = requests.get(url)
# soup = BeautifulSoup(reqs.text, 'html.parser')

# urls = []
# for link in soup.find_all('a'):
#     urls.append(link.get('href'))

# with open("/dev/shm/urls.txt", "w+") as f:
#     f.write('\n'.join([u if not u.startswith("./") else u[2:] for u in urls]))

# print("Found URLs:")
# print(urls)

# strings = extract_php_strings_from_files(list_all_files("/var/www/"))
# with open("/dev/shm/strings.txt", "w+") as f:
#     f.write('\n'.join(strings))

# print(f"Found strings: {len(strings)}")

# _wfuzz_cookie_arg = f'-b "{wfuzz_cookie_arg}"' if with_login else ""
# _exec_str = f'wfuzz --script=default,verbose,discover -Z -w /dev/shm/urls.txt --no-cache {_wfuzz_cookie_arg} -u http://localhost/FUZZ'
# print(_exec_str)
# os.system(_exec_str)

# print("##################")
# print("Starting second stage...")
# time.sleep(10)
# _exec_str = f'wfuzz --script=default,verbose,discover -Z -w /dev/shm/urls.txt -w /common.txt -w /All_attack.txt --no-cache -d "FUZ2Z=FUZ3Z" {_wfuzz_cookie_arg} -u http://localhost/FUZZ'
# print(_exec_str)
# os.system(_exec_str)