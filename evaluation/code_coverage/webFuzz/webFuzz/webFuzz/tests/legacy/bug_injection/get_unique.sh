#!/bin/bash

./get_log.sh 10.16.20.24 sess_remote

old_m=`cat magics.dat | cut -d ' ' -f 3 | tr '\n' ':'`

echo $old_m

grep 'LCov:' ../fuzzer.log | head -n 1 > localhost.log

grep 'Possible xss' ../fuzzer.log >> localhost.log
python test_bugs.py localhost.log trash.dat

all=`cat magics.dat`
new_m=`cat magics.dat | cut -d ' ' -f 3`
echo 'total found in 2nd run: ' `echo "$new_m" | wc -l`

lineNum=0
xssCount=`cat dat_bugs.dat | tail -n 1 | cut -d ' ' -f 3`

for m in $new_m; do
   ((lineNum += 1))
   [[ ! -z `echo $old_m | grep $m` ]] && continue
   ((xssCount++))
   echo "$all" | sed -n -e "$lineNum p"
   echo `echo "$all" | sed -n -e "$lineNum p" | cut -d ' ' --complement -f 3` $xssCount >> dat_bugs.dat
done
