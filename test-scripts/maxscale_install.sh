#!/bin/bash

# $1 - image
# $2 - IP
# $3 - target

set -x

image=$1
IP=$2
target=$3

cat /home/ec2-user/test-scripts/maxscale.repo.template | sed "s/###target###/$target/" | sed "s/###image###/$image/" >  /home/ec2-user/test-scripts/maxscale.repo
scp -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ec2-user/test-scripts/maxscale.repo root@$IP:/etc/yum.repos.d/
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/yum_files/$image/* root@$IP:/etc/yum.repos.d/

ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP "yum clean all; yum -y install maxscale"
