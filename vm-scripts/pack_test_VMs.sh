#!/bin/bash

# $1 - last digits of IP
# $2 - number of machines
# $3 - archive name

set -x 
x=`expr $1 + $2 - 1`
s=""
for i in $(seq $1 $x)
do
	image=`cat /home/ec2-user/test-machines/image_name_192.168.122.$1`
	ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i "shutdown now"
	sleep 20
        cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$i
	s="$s test_vm_192.168.122.$i.img image_name_192.168.122.$i"
	if [ -f /home/ec2-user/test-machines/lock_192.168.122.$i ] ; then 
		s="$s  lock_192.168.122.$i"
	fi
done
sleep 10
cd /home/ec2-user/test-machines/
tar czvf /home/ec2-user/vm-archives/$3.tar.gz $s
