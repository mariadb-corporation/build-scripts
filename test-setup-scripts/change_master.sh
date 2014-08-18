#!/bin/bash

# $1 - image name
# $2 - last digits of IP
# $3 - number of machines
# $4 - last digits pf IP of current master 
# $5 - last digits pf IP of new master

set -x

image_name="$1"
IP_end="$2"
N="$3"

old_master="$4"
new_master="$5"

Master_IP=`expr $IP_end + 1`
First_slave=`expr $IP_end + 2`

x=`expr $IP_end + $N - 1`

scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/create_*_user.sql root@192.168.122.$new_master:/root/
ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$new_master 'mysql < /root/create_repl_user.sql'


x=`expr $IP_end + $N - 1`
for i in $(seq $Master_IP $x)
do
	if [ "$i" != "$old_master" ] ; then
		ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'echo "stop slave;" | mysql '
	fi

	if [ "$i" != "$new_master" ] ; then
		log_file=`ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$new_master 'echo "SHOW MASTER STATUS\G;" | mysql ' | grep "File:" | sed "s/File://" | sed "s/ //g"`
		log_pos=`ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$new_master 'echo "SHOW MASTER STATUS\G;" | mysql ' | grep "Position:" | sed "s/Position://" | sed "s/ //g"`

		sed "s/###IP###/$new_master/" /home/ec2-user/test-setup-scripts/setup_slave.sql.template | sed "s/###LOG_FILE###/$log_file/" | sed "s/###LOG_POS###/$log_pos/" > /home/ec2-user/test-setup-scripts/setup_slave.sql
	        scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/setup_slave.sql root@192.168.122.$i:/root/

		ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'mysql < /root/setup_slave.sql'
		ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'echo "start slave;" | mysql '
	fi
done

#ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$new_master 'mysql < /root/create_skysql_user.sql'

