#!/bin/bash

# $1 - image
# $2 - target IP
# $3 - ssh key

set -x

/home/ec2-user/kvm/start_kvm_c.sh $1 

sleep 5
x=1
while [  "$x" -ne 0 ]; do
       echo "Tryng ssh to 192.168.122.2"  
       ssh -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 'ls > /dev/null'
       x=$?
done
scp -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  /home/ec2-user/vm-scripts/generate_hosts.sh root@192.168.122.2:/root/
ssh -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 "/root/generate_hosts.sh"
ssh -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 "rm /root/generate_hosts.sh"


cat /home/ec2-user/test-machines/image_name_$2 | grep "fedora"
if [ $? == 0 ] ; then
	scp -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/kvm/ifcfg-fedora/$2/* root@192.168.122.2:/etc/sysconfig/network-scripts/
	ssh -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 "shutdown now"
else
	cat /home/ec2-user/test-machines/image_name_$2 | grep -i "suse"
	if [ $? == 0 ] ; then
		scp -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/kvm/ifcfg-opensuse/$2/* root@192.168.122.2:/etc/sysconfig/network/
		ssh -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 "shutdown now" &
	else
		scp -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/kvm/ifcfg/$2/* root@192.168.122.2:/etc/sysconfig/network-scripts/
		ssh -i $3 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 "shutdown now"
	fi
fi
sleep 20
cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket002

ssh-keygen -f "/home/ec2-user/.ssh/known_hosts" -R $2
