#!/bin/bash

# $1 - image name
# $2 - last digits of IP
# $3 - number of VMs

image_name="$1"
IP_end="$2"
N="$3"

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end 'service iptables stop; yum install -y MariaDB-test MariaDB-client'

scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/test-scripts/Hartmut_tests/maxscale-mysqltest root@192.168.122.$IP_end:/home/ec2-user/

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end 'cd /home/ec2-user/maxscale-mysqltest/ ; ./test.sh'
