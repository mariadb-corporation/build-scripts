#!/bin/bash

# $1 - image name
# $2 - last digits of IP
# $3 - number of VMs

image_name="$1"
IP_end="$2"
N="$3"

scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/test-scripts/test_ctrl_c/* root@192.168.122.$IP_end:/home/ec2-user/

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end '/home/ec2-user/test_ctrl_c.sh'
