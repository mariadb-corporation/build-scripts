#!/bin/bash

# $1 - last digits of IP
# $2 - number of machines

x=`expr $1 + $2 - 1`
for i in $(seq $1 $x)
do
	cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$i
done

cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket2
cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket002

echo "all stop signals are sent"

