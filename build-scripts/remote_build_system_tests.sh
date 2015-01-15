#!/bin/bash

set -x

scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/build-scripts/build_system_tests.sh root@$IP:/root/
tar cf - * | ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP "tar xf - "
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r ./* root@$IP:/root/

scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/apt_files-$MariaDBVersion/$image/* root@$IP:/etc/apt/sources.list.d/
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/yum_files-$MariaDBVersion/$image/* root@$IP:/etc/yum.repos.d/

scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/vm_setup_scripts/$image.sh root@$IP:/root/
ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP /root/$image.sh

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP /root/build_system_tests.sh

scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/sysbench_deb7/ root@$IP:/home/ec2-user/
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/test-scripts/ root@$IP:/home/ec2-user/
