#!/bin/bash

# $1 - maxscale.cnf.template suffix (tamplete name, currently "galera" or "replication")
# $2 - last digits of IP of the cluster

set -x

template=$1
ip=$2


if [ -z $template ] ; then
  template="replication"
fi

cp /home/ec2-user/test-scripts/maxscale.cnf.template.$template /home/ec2-user/test-scripts/MaxScale.cnf
if [ $? -ne 0 ] ; then
	echo "error copying maxscale.cnf file"
fi

for i in $(seq 1 4)
do
	ip=`expr $IP_end + $i`
	sed -i "s/###server_IP_$i###/192.168.122.$ip/"  /home/ec2-user/test-scripts/MaxScale.cnf
done

max_dir="/usr/local/skysql/maxscale/"
scp -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ec2-user/test-scripts/MaxScale.cnf root@$Maxscale_IP:$max_dir/etc/
ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$Maxscale_IP "$max_dir/bin/maxkeys $max_dir/etc/.secrets"
ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$Maxscale_IP "rm $max_dir/log/*.log ; rm /tmp/core*; service maxscale restart" &
sleep 30
