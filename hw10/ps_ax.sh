#!/bin/bash

# Clear ps.txt
echo -n > ps.txt

# Get all pids from /proc
ls /proc/ | grep -o '[0-9]*' > ./all_pid.txt

echo "PID TTy STAT TIME COMMAND" > ps.txt

# Get PID TTy STAT (Time) COMMAND
allpid="./all_pid.txt"
lines=$(cat $allpid)
for i in $lines
do
    command=$(echo $(cat /proc/$i/cmdline))
    apid=$(awk -F " " '{print $1}' /proc/$i/stat)
    tty=$(awk -F " " '{print $7}' /proc/$i/stat)
    stat=$(awk -F " " '{print $3}' /proc/$i/stat)
    time=$(awk -v ticks="$(getconf CLK_TCK)" '{print strftime ("%M:%S", ($14+$15)/ticks)}' /proc/1/stat)
    #awk -F " " '{print $2}'/proc/$i/cmdline
    #paste -d ' ' <(cut -d' ' -f1 ps1.txt) <(cut -d' ' -f2 ps1.txt) <(cut -d' ' -f3 ps1.txt) <(cut -f1 ps2.txt) > ps.txt
    echo -e "$apid    \t $stat $time $command" >> ps.txt
done

#RESULT
#column -t -s' ' ps.txt | less
