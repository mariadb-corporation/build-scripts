#!/bin/bash

for i in $(seq 1 255)
do
	cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$i
done

cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket2
cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket002

echo "all stop signals are sent"

