chmod +x hget
cp hget /tmp/
cd /tmp/
echo 0 > /proc/sys/kernel/randomize_va_space
echo 0 > /proc/sys/kernel/printk
./hget hcat_no_pt hcat
./hget habort_no_pt habort
chmod +x hcat
chmod +x habort
# copy php.ini
./hget php.ini php.ini
chmod 777 php.ini

echo "Starting docker" | ./hcat
stdbuf -i0 -o0 -e0 service docker start 2>&1 | ./hcat

echo "Install vmtouch" | ./hcat
./hget vmtouch vmtouch
chmod +x vmtouch

echo "Let's get our target executable..." | ./hcat 
./hget atropos_agent atropos_agent
chmod +x atropos_agent
./hget crash crash
./hget crashlfi crashlfi
chmod +x /tmp/crash
chmod 777 /tmp/crash
chmod +x /tmp/crashlfi
chmod 777 /tmp/crashlfi
./hget bug.php bug.php 
./hget preload.php preload.php 
./hget crash.php crash.php 

echo "Getting docker snapshot..." | ./hcat 
./hget webapp-snapshot.tar webapp-snapshot.tar
ls -lah . | ./hcat

echo "Loading docker snapshot..." | ./hcat 
docker load -i webapp-snapshot.tar 2>&1 | ./hcat

echo "Deleting tar snapshot file..." | ./hcat 
rm webapp-snapshot.tar 2>&1 | ./hcat

echo "Running container..." | ./hcat 
docker run -td -v /tmp:/tmp --name=webapp webapp-snapshot 2>&1 | ./hcat

echo "Executing modified PHP inside docker container..." | ./hcat 
docker cp /tmp/. webapp:/tmp/ 2>&1 | ./hcat
docker exec -t webapp bash -ic "find / -name libssl.so.1.1 2>&1 | /tmp/hcat; cp /atropos/targ* /tmp/; chmod +x /tmp/atropos_agent /tmp/target_executable; ls -lah /tmp; cp /tmp/*.php /var/www/html; chmod +x /tmp/crash /tmp/crashlfi; cd /var/www/html; declare -x IN_NYX=1; export IN_NYX=1; echo calling tmp atropos_agent | /tmp/hcat; IN_NYX=1 LD_LIBRARY_PATH=/tmp/ LD_BIND_NOW=1 /tmp/atropos_agent >> /tmp/out.txt 2>&1" # >> /tmp/out.txt 2>&1")

docker cp webapp:/tmp/out.txt /tmp/
cat /tmp/out.txt | ./hcat
echo "Done executing..." | ./hcat 
dmesg | grep segfault | ./hcat
./habort
