#!/bin/bash

# $1 - image name
# $2 - last digist of IP
# $3 - number of machines

set -x

image_name="$1"
IP_end="$2"
N="$3"

Master_IP=`expr $IP_end + 1`
First_slave=`expr $IP_end + 2`

x=`expr $IP_end + $N - 1`
for i in $(seq $Master_IP $x)
do
	scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/yum_files/$image_name/* root@192.168.122.$i:/etc/yum.repos.d/
	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'yum clean all; yum install -y MariaDB-server MariaDB-client'
	sed "s/###SERVER_ID###/$i/"  /home/ec2-user/test-setup-scripts/server.cnf.template >  /home/ec2-user/test-setup-scripts/server.cnf

	scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/server.cnf root@192.168.122.$i:/etc/my.cnf.d/
	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i '/etc/init.d/mysql start'

	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp -m tcp --dport 3306 -j ACCEPT'
	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp --dport 3306 -j ACCEPT -m state --state NEW'
done

scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/create_repl_user.sql root@192.168.122.$Master_IP:/root/
ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP 'mysql < /root/create_repl_user.sql'


x=`expr $IP_end + $N - 1`
for i in $(seq $First_slave $x)
do
	log_file=`ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP 'echo "SHOW MASTER STATUS\G;" | mysql ' | grep "File:" | sed "s/File://" | sed "s/ //g"`
	log_pos=`ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP 'echo "SHOW MASTER STATUS\G;" | mysql ' | grep "Position:" | sed "s/Position://" | sed "s/ //g"`

	sed "s/###IP###/$Master_IP/" /home/ec2-user/test-setup-scripts/setup_slave.sql.template | sed "s/###LOG_FILE###/$log_file/" | sed "s/###LOG_POS###/$log_pos/" > /home/ec2-user/test-setup-scripts/setup_slave.sql
        scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/setup_slave.sql root@192.168.122.$i:/root/

	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'mysql < /root/setup_slave.sql'
done

