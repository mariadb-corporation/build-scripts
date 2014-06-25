#!/bin/bash

# $1 - last digits of IP
# $2 - number of machines

x=`expr $1 + $2 - 1`
for i in $(seq $1 $x)
do
	image=`cat /home/ec2-user/test-machines/image_name_192.168.122.$1`
	ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i "shutdown now"
	sleep 20
        cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$i
done
