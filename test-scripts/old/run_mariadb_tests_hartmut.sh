#!/bin/bash

# $1 - image name
# $2 - last digits of IP
# $3 - number of VMs

image_name="$1"
IP_end="$2"
N="$3"
Master_IP=`expr $IP_end + 1`

cat /home/ec2-user/test-scripts/Hartmut_tests/maxscale-mysqltest/r/test_implicit_commit4.result.template | sed "s/####server_id####/$Master_IP/" > /home/ec2-user/test-scripts/Hartmut_tests/maxscale-mysqltest/r/test_implicit_commit4.result
cat /home/ec2-user/test-scripts/Hartmut_tests/maxscale-mysqltest/r/select_for_var_set.result.template | sed "s/####server_id####/$Master_IP/" > /home/ec2-user/test-scripts/Hartmut_tests/maxscale-mysqltest/r/select_for_var_set.result

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end 'service iptables stop; yum install -y MariaDB-test MariaDB-client'

scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/test-scripts/Hartmut_tests/maxscale-mysqltest root@192.168.122.$IP_end:/home/ec2-user/

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end 'cd /home/ec2-user/maxscale-mysqltest/ ; ./test.sh'

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end "cat /home/ec2-user/maxscale-mysqltest/fail.txt" | grep "FAILED"
if [ $? == 0 ] ; then
   exit 1
else
   exit 0
fi
