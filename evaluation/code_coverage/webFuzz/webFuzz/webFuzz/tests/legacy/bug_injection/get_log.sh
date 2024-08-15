#!/bin/bash

# make sure ssh login through public/private key pairs is set up

IP=$1
SUFFIX=$2
DIR=/home/orpheas/fuzzing/hhvm-fuzzing/web_fuzzer
FILE=bugs_${SUFFIX}_`date +%d_%m_%H:%M`

ssh orpheas@${IP} << _EOF_
cd $DIR
grep 'LCov:' fuzzer.log | head -n 1 > /tmp/${FILE}
grep 'Possible xss found in key' fuzzer.log >> /tmp/${FILE}
_EOF_

sftp orpheas@${IP} <<< "get /tmp/${FILE}"

python test_bugs_strict.py $FILE dat_bugs.dat
