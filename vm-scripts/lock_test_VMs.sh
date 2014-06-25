#!/bin/bash

# $1 - last digits of IP
# $2 - number of machines

x=`expr $1 + $2 - 1`
for i in $(seq $1 $x)
do
	touch /home/ec2-user/test-machines/lock_192.168.122.$i
done


