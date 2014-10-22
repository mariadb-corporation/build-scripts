#!/bin/bash

image=`cat /home/ec2-user/test-machines/image_name_$1`
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$1:/usr/local/skysql/maxscale/log/* .

