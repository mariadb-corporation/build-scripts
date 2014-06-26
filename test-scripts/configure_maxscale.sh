#!/bin/bash

# $1 - image
# $2 - last digits of IP

set -x

IP_end=$2
image=$1

cp /home/ec2-user/test-scripts/maxscale.cnf.template /home/ec2-user/test-scripts/MaxScale.cnf

for i in $(seq 1 4)
do
	ip=`expr $IP_end + $i`
	sed -i "s/###server_IP_$i###/192.168.122.$ip/"  /home/ec2-user/test-scripts/MaxScale.cnf
done

scp -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ec2-user/test-scripts/MaxScale.cnf root@192.168.122.$IP_end:/usr/local/sbin/MaxScale/etc/
ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.122.$IP_end "/usr/local/sbin/bin/maxkeys /usr/local/sbin/MaxScale/etc/.secrets"
ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@192.168.122.$IP_end "/usr/local/sbin/bin/maxscale -c /usr/local/sbin/MaxScale/" &
disown