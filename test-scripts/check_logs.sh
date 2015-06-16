#!/bin/bash

set -x

date_str=`date +%Y%m%d-%H`
logs_dir="/var/www/html/test/logs/$date_str/$value/$image/$test_name/"
mkdir -p $logs_dir

cp -r LOGS/$test_name/* $logs_dir

#echo "log_dir:         $logs_dir"
#echo "Maxscale_sshkey: $Maxscale_sshkey"
#echo "Maxscale_IP:     $Maxscale_IP"
#scp -i $Maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:$maxdir/log/* $logs_dir
#scp -i $Maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:/tmp/core* $logs_dir
#scp -i $Maxscale_sshkey -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$Maxscale_IP:$maxdir/etc/* $logs_dir
chmod a+r $logs_dir/*
