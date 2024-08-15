#!/bin/bash

./get_log.sh 10.16.20.24 sess_remote

NOTCOUNT=4
magics=`cat magics.dat | cut -d ' ' -f 3 | head -n -${NOTCOUNT}`
old_m=`cat magics.dat | cut -d ' ' -f 3 | head -n -${NOTCOUNT} | tr '\n' ':'`
old_dat=`cat dat_bugs.dat | head -n -${NOTCOUNT}`
echo $old_m

./get_log.sh 10.16.20.23 sess_remote

all=`cat magics.dat`
new_m=`cat magics.dat | cut -d ' ' -f 3`
echo 'total found in 2nd run: ' `echo "$new_m" | wc -l`

echo "$old_dat" > dat_bugs.dat

lineNum=0
xssCount=`cat dat_bugs.dat | tail -n 1 | cut -d ' ' -f 3`

for m in $new_m; do
   ((lineNum += 1))
   [[ ! -z `echo $old_m | grep $m` ]] && continue
   ((xssCount++))
   echo "$all" | sed -n -e "$lineNum p"
   echo `echo "$all" | sed -n -e "$lineNum p" | cut -d ' ' --complement -f 3` $xssCount >> dat_bugs.dat
done

echo "$magics" > magics_raw.dat
echo "$new_m" >> magics_raw.dat
