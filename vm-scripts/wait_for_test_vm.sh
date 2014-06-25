#!/bin/bash
# $1 - image
# $2 - last digits of IPP

x=1
while [  "$x" -ne 0 ]; do
       echo "Tryng ssh to 192.168.122.$1"  
       ssh -i /home/ec2-user/KEYS/$1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$2 'ls > /dev/null'
       x=$?
done
sleep 20

