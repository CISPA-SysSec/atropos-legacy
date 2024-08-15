#!/usr/bin/env bash

set -eExuo pipefail

dnsmasq --no-daemon &

/wapiti_endpoint.sh &

# Wait for endpoint to start
while ! curl --output /dev/null --silent --head --fail http://localhost:8000; do
    sleep 0.1 && echo -n .
done

if [ ! -f /wapiti_context/args ]; then
    echo "File /wapiti_context/args not found."
    exit 1
fi

chmod 777 -R /zap
chmod 777 -R /tmp
wapiti $(</wapiti_context/args) --module backup,cookieflags,crlf,csp,csrf,drupal_enum,exec,file,htaccess,htp,http_headers,methods,nikto,permanentxss,redirect,shellshock,sql,ssl,ssrf,takeover,timesql,wapp,wp_enum,xss,xxe --scope folder --endpoint http://localhost:8000/ --dns-endpoint 127.0.0.1 --color --verbose 2 --flush-session --tasks 32 --detailed-report --output /zap/wrk/wapiti_${APP_TAG}_$(date +%Y-%m-%d_%H:%M:%S)/



        # log4shell,buster,brute_login_form,
        #         Detect the Log4Shell vulnerability (CVE-2021-44228)
