#!/bin/bash

#yum install -y MariaDB-test
cd /usr/share/mysql-test/t/
list=`ls -1 *.test | sed "s/\.test//"`
cd ..

for t in $list
do
	echo $t
	mysqltest -P 4008 -u skysql -pskysql -h 192.168.122.105 --result-file=r/$t.result test < t/$t.test
done
