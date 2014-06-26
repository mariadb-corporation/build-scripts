#!/bin/bash

# $1 - image name
# $2 - last digist of IP
# $3 - number of machines

set -x

image_name="$1"
IP_end="$2"
N="$3"

Master_IP=`expr $IP_end + 1`
First_slave=`expr $IP_end + 2`

#/home/ec2-user/test-setup-scripts/generate_hosts.sh > /home/ec2-user/test-setup-scripts/hosts

x=`expr $IP_end + $N - 1`
for i in $(seq $Master_IP $x)
do
	scp -r -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/galera/* root@192.168.122.$i:/root/
	scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/yum_files/$image_name/* root@192.168.122.$i:/etc/yum.repos.d/

	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i "/root/install-packages.sh ; /root/firewall-setup.sh 192.168.122.$IP_end; /root/configure.sh 192.168.122.$i node$i"

done


ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP "/etc/init.d/mysql start --wsrep-cluster-address=gcomm://"
sleep 10

for i in $(seq $First_slave $x)
do
	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i "/etc/init.d/mysql start --wsrep-cluster-address=gcomm://192.168.122.$Master_IP" &
	sleep 10
done


disown
