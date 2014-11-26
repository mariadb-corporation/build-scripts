#!/bin/bash

date_str=`date +%Y%m%d`
logs_dir="/var/www/html/test/logs/$date_str/$value/$image/$Test_name/"
mkdir -p $logs_dir
scp -i $Maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/usr/local/skysql/maxscale/log/* $logs_dir
scp -i $Maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/tmp/core* $logs_dir
scp -i $Maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/usr/local/skysql/maxscale/etc/* $logs_dir
chmod a+r $logs_dir/*
