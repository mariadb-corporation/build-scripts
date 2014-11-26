#!/bin/bash

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP 'service iptables stop'

#scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-scripts/server* ec2-user@$BuildIP:/home/ec2-user/
#scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-scripts/setup_3mariadb.sh ec2-user@$BuildIP:/home/ec2-user/
#ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$BuildIP 'export BuildIP="$BuildIP"; /home/ec2-user/setup_3mariadb.sh "$BuildIP"' &

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP "cp -r /home/ec2-user/workspace/* /usr/local/skysql/maxscale/ ; cd /usr/local/skysql/maxscale/ ; cmake . -DSTATIC_EMBEDDED=Y -DGCOV=Y $cmake_flags; make; make install "

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP "sed -i  \"s/start() {/start() { export DAEMON_COREFILE_LIMIT='unlimited'/\" /etc/init.d/maxscale"

