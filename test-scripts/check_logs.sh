#!/bin/bash

date_str=`date +%Y%m%d`
logs_dir="/var/www/html/test/logs/$date_str/$value/$image/$Test_name/"
mkdir -p $logs_dir
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/usr/local/skysql/maxscale/log/* $logs_dir
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/tmp/core* $logs_dir

