#!/bin/bash
# $1 - IP
IFS=. read ip1 ip2 ip3 ip4 <<< "$1"
echo $ip1
echo $ip2
echo $ip3
echo $ip4
/home/ec2-user/vm-scripts/start_VM.sh $ip4
