#!/bin/bash

set -x

mkdir -p /home/ec2-user/workspace/server/test/MaxScale/etc

/usr/bin/mysql_install_db --defaults-file=/home/ec2-user/server1.cnf
/usr/bin/mysqld_safe --defaults-file=/home/ec2-user/server1.cnf &

/usr/bin/mysql_install_db --defaults-file=/home/ec2-user/server2.cnf
/usr/bin/mysqld_safe --defaults-file=/home/ec2-user/server2.cnf &

/usr/bin/mysql_install_db --defaults-file=/home/ec2-user/server3.cnf
/usr/bin/mysqld_safe --defaults-file=/home/ec2-user/server3.cnf &

sleep 30

/usr/bin/mysqladmin -u root password 'skysql' -h localhost -P 3000 -S /tmp/mysql1.sock
/usr/bin/mysqladmin -u root password 'skysql' -h localhost -P 3001 -S /tmp/mysql2.sock
/usr/bin/mysqladmin -u root password 'skysql' -h localhost -P 2002 -S /tmp/mysql3.sock

echo "GRANT ALL PRIVILEGES ON *.* TO FOO;"  |  mysql -h localhost -P 3000 -S /tmp/mysql1.sock -u root -pskysql
echo "GRANT ALL PRIVILEGES ON *.* TO test;"  |  mysql -h localhost -P 3000 -S /tmp/mysql1.sock -u root -pskysql
echo "grant replication slave on *.* to repl identified by 'repl';"  |  mysql -h localhost -P 3000 -S /tmp/mysql1.sock -u root -pskysql

log_file=`echo "show master status\G" | mysql -h localhost -uroot -pskysql -S /tmp/mysql1.sock -P 3000 | grep "File:" | sed "s/File://" | sed "s/ //g"`
log_pos=`echo "show master status\G" | mysql -h localhost -uroot -pskysql -S /tmp/mysql1.sock -P 3000 |  grep "Position:" | sed "s/Position://" | sed "s/ //g"`


echo "change master to MASTER_HOST='192.168.122.2';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql2.sock -P 3001 
echo "change master to MASTER_PORT=3000;"  | mysql -h localhost -uroot -pskysql -S /tmp/mysql2.sock -P 3001
echo "change master to MASTER_USER='repl';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql2.sock -P 3001 
echo "change master to MASTER_PASSWORD='repl';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql2.sock -P 3001 
echo "change master to MASTER_LOG_FILE='$log_file';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql2.sock -P 3001 
echo "change master to MASTER_LOG_POS=$log_pos;" | mysql -h localhost -uroot -pskysql -S /tmp/mysql2.sock -P 3001 
echo "start slave;" | mysql -h localhost -uroot -pskysql -S /tmp/mysql2.sock -P 3001 

echo "change master to MASTER_HOST='192.168.122.2';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql3.sock -P 2002
echo "change master to MASTER_PORT=3000;"  | mysql -h localhost -uroot -pskysql -S /tmp/mysql3.sock -P 2002
echo "change master to MASTER_USER='repl';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql3.sock -P 2002
echo "change master to MASTER_PASSWORD='repl';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql3.sock -P 2002
echo "change master to MASTER_LOG_FILE='$log_file';" | mysql -h localhost -uroot -pskysql -S /tmp/mysql3.sock -P 2002 
echo "change master to MASTER_LOG_POS=$log_pos;" | mysql -h localhost -uroot -pskysql -S /tmp/mysql3.sock -P 2002 
echo "start slave;" | mysql -h localhost -uroot -pskysql -S /tmp/mysql3.sock -P 2002

disown
