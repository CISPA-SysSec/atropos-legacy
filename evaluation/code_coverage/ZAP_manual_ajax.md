# Description of the manual process to run ZAP

## Recommended reading:
https://www.zaproxy.org/docs/docker/webswing/
Though, most is automated already.

## First start container:

```
# first terminal
$ PROG=espocrm TOOL=ZAP ./build-images.sh # wait for server to start up

# second terminal
$ PROG=espocrm TOOL=ZAP ./exec-images.sh # this runs `docker exec`
# in the docker container run:
root@ed8ebce78068:/zap# /webswing.sh # this starts up the ZAP app
```

## Set up certificate (needs only to be done once):
No need to create a new certificate, use the certificate in the tmp/zap folder.
https://www.zaproxy.org/docs/docker/webswing/#proxying-through-zap

## Start up webswing app
http://localhost:8080/zap

Access url and wait for app to start.

## Start proxied browser
Use about:profiles (in firefox) to start new browser session.

Then access http://localhost in that browser window.
If it is automatically redirected to https://localhost, turn off HUD:

In webswing app, open "Tools" -> "Options ..."
Select "HUD" -> deselect "Enable when using the ZAP Desktop -> OK

Then open http://localhost again.

## Import context for app
In webswing app, open "File" -> "Import Context" -> Look In: /zap/wrk/ -> Open: "<app>.context"

## Set up logged in http context
In the browser login, see <app>/README.txt for username / password.

In webswing, use green cross to access "Params", select session token (see README) and flag it as session token.
Next use green cross to acess "HTTP Sessions", there should be one session, set it as active.

Everything is now prepared for the analysis.

## Run Analysis
In webswing, use Quick Start tab to select automated analysis.
URL to attack is in app README, select both spiders (Firefox Headless for ajax spider) and start Attack.
After both spiders and Scan has run through the report can be produced, see Progress message.

## Get Report
In webswing, use Report tab ...