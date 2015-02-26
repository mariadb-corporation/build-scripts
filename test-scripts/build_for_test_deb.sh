#!/bin/bash

set -x

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP 'service ufw stop'

#scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-scripts/server* ec2-user@$BuildIP:/home/ec2-user/
#scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-scripts/setup_3mariadb.sh ec2-user@$BuildIP:/home/ec2-user/
#ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$BuildIP 'export BuildIP="$BuildIP"; /home/ec2-user/setup_3mariadb.sh "$BuildIP"' &

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP "cp -r /home/ec2-user/workspace/* /usr/local/skysql/maxscale/ ; cd /usr/local/skysql/maxscale/ ; mkdir _build; cd _build; cmake .. -DSTATIC_EMBEDDED=Y -DGCOV=Y -DERRMSG=/usr/share/english/errmsg.sys  -DBUILD_RABBITMQ=N -DEMBEDDED_LIB=/usr/lib/ $cmake_flags; make; make install "

#ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP "sed -i  \"s/start() {/start() { export DAEMON_COREFILE_LIMIT='unlimited'/\" /etc/init.d/maxscale"

scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-scripts/add_core_cnf.sh root@$BuildIP:/root/
ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP "/root/add_core_cnf.sh"
