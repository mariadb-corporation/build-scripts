#!/bin/bash

# $1 - image name
# $2 - last digits of IP
# $3 - number of VMs

image_name="$1"
IP_end="$2"
N="$3"

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end 'service iptables stop'

/home/ec2-user/test-scripts/c/connect_rw 192.168.122.$IP_end &
sleep 10
ps ax | grep mysql

Master_IP=`expr $IP_end + 1`
New_Master_IP=`expr $IP_end + 2`

/home/ec2-user/test-scripts/processlist_rwsplit.sh $Master_IP

set -x
/home/ec2-user/test-scripts/c/rw_select_insert $IP_end $N
