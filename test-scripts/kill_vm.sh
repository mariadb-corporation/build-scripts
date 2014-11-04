#!/bin/bash
# $1 - IP
IP=$1

IFS=. read ip1 ip2 ip3 ip4 <<< "$IP"
echo $ip1
echo $ip2
echo $ip3
echo $ip4
/home/ec2-user/vm-scripts/stop_one_VM.sh $ip4
echo "sleeping 5 seconds"
sleep 5
echo "Checking process list for qemu processes with $IP"
PIDs=`ps ax | grep "$IP" | grep qemu | sed -e 's/^[ \t]*//' | cut -d' ' -f1`
echo $PIDs
for PID in $PIDs; do
        echo "Killing process $PID"
        sudo kill $PID
done

