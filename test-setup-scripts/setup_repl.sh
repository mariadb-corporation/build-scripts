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

image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$image_name".img | sed "s/$image_name.img//" | sed "s/ //g"`
echo "image type is $image_type"
if [ "$image_type" != "RPM" ] && [ "$image_type" != "DEB" ] ; then
        echo "unknown image type: should be RPM or DEB"
        exit 1
fi


x=`expr $IP_end + $N - 1`
for i in $(seq $IP_end $x)
do
    if [ "$i" != "$IP_end" ] ; then
        if [ "$image_type" != "RPM" ] ; then
                scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/apt_files/$image_name/* root@192.168.122.$i:/etc/apt/sources.list.d/
                ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'apt-get update; apt-get install -y --force-yes mariadb-server mariadb-client'
		ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf'
		ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld; service apparmor restart'
		dir="/etc/mysql/conf.d/"
        else 
		echo $1 | grep -i "opensuse"
		if [ $? == 0 ] ; then
		        ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'zypper -n install mariadb mariadb-client'
                        dir="/etc/my.cnf.d/"
		else
			scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/yum_files/$image_name/* root@192.168.122.$i:/etc/yum.repos.d/
			echo $1 | grep -i "centos7"
			if [ $? == 0 ] ; then
				ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'yum clean all; yum install -y mariadb-server mariadb'
			else
				ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'yum clean all; yum install -y MariaDB-server MariaDB-client'
			fi 
			dir="/etc/my.cnf.d/"
		fi
	fi
	sed "s/###SERVER_ID###/$i/"  /home/ec2-user/test-setup-scripts/server.cnf.template >  /home/ec2-user/test-setup-scripts/server.cnf

	scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/server.cnf root@192.168.122.$i:$dir
    fi

    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp -m tcp --dport 3306 -j ACCEPT'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp --dport 3306 -j ACCEPT -m state --state NEW'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp -m tcp --dport 4006 -j ACCEPT'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp --dport 4006 -j ACCEPT -m state --state NEW'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp -m tcp --dport 4008 -j ACCEPT'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp --dport 4009 -j ACCEPT -m state --state NEW'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp -m tcp --dport 4008 -j ACCEPT'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp --dport 4008 -j ACCEPT -m state --state NEW'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp -m tcp --dport 4442 -j ACCEPT'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp --dport 4442 -j ACCEPT -m state --state NEW'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp -m tcp --dport 6444 -j ACCEPT'
    ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'iptables -I INPUT -p tcp --dport 6444 -j ACCEPT -m state --state NEW'

    if [ "$i" != "$IP_end" ] ; then
	echo $1 | grep -i "centos7"
        if [ $? != 0 ] ; then
		ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i '/etc/init.d/mysql restart'
	else
		ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'systemctl start mariadb.service'
	fi
   fi

done

scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/create_*_user.sql root@192.168.122.$Master_IP:/root/
ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP 'mysql < /root/create_repl_user.sql'


x=`expr $IP_end + $N - 1`
for i in $(seq $First_slave $x)
do
	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'mysql < /root/create_repl_user.sql'
	log_file=`ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP 'echo "SHOW MASTER STATUS\G;" | mysql ' | grep "File:" | sed "s/File://" | sed "s/ //g"`
	log_pos=`ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP 'echo "SHOW MASTER STATUS\G;" | mysql ' | grep "Position:" | sed "s/Position://" | sed "s/ //g"`

	sed "s/###IP###/$Master_IP/" /home/ec2-user/test-setup-scripts/setup_slave.sql.template | sed "s/###LOG_FILE###/$log_file/" | sed "s/###LOG_POS###/$log_pos/" > /home/ec2-user/test-setup-scripts/setup_slave.sql
        scp -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-setup-scripts/setup_slave.sql root@192.168.122.$i:/root/

	ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i 'mysql < /root/setup_slave.sql'
done

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$Master_IP 'mysql < /root/create_skysql_user.sql'

