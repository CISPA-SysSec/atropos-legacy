#!/bin/bash

pushd ./docker-base/
# copy pcov
rm -rf ./php-src
cp -r ../php-7*/ ./php-src
rm -rf ./php-src/.git
# copy pcov
rm -rf ./pcov
cp -r ../pcov-nyx ./pcov
rm -rf ./pcov/.git
docker build --tag=webapp-base . || exit 1
popd

pushd $1

echo "Delete previous builds"
docker stop webapp
docker rm webapp 2>/dev/null
docker rm webapp-snapshot 2>/dev/null

# copy browser_data.php
cp ../browser_data.php ./

echo "Building new docker image"
docker build --tag=webapp-img . || exit 1
echo "Running webserver on port 8000, launch http://localhost:8000 to setup, login etc. | ssh -L 8000:localhost:8000 user@host"
echo "Press CTRL+C once when you are finished"
docker run -it -p 8000:80 --entrypoint /main.sh -v /dev/shm:/dev/shm --name webapp webapp-img 
echo "Committing changes back to image"
docker commit webapp webapp-snapshot
echo "Exporting image"
docker save webapp-snapshot > webapp-snapshot.tar # export the image
cp webapp-snapshot.tar ../webapp_share/
echo "Copying html folder to host"
sudo rm -rf /dev/shm/html
docker load -i webapp-snapshot.tar
docker run --rm -it --entrypoint "/copy_html.sh" -v /dev/shm:/dev/shm webapp-snapshot
rm -rf ./html_bkp
cp -pr /dev/shm/html ./html_bkp
cp ../browser_data.json ./

popd
