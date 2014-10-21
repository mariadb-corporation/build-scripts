#!/bin/bash

date_str=`date +%Y%m%d`
logs_dir=/var/www/html/logs/$date_str/$values/$image
mkdir -p $logs_dir
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/usr/local/skysql/maxscale/logs/* $logs_dir
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/tmp/core* $logs_dir

