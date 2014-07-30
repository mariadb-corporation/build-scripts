#!/bin/bash

image=$1

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@192.168.122.2 'cd /home/ec2-user/workspace/; cat ./server/test/testserver.log ./server/test/log/skygw_err1.log ./server/test/log/skygw_msg1.log ./server/test/log/skygw_debug1.log ./server/test/log/skygw_trace1.log ./utils/test/testutils.log ./log_manager/test/testlog.log ./server/modules/routing/test/testrouting.log ./server/modules/routing/readwritesplit/test/testrwsplit.log ./server/core/test/testhash.log' > all_logs

cat all_logs

echo "*******************************"
echo "** Checking for FAILED cases **"
echo "*******************************"

cat all_logs | grep "FAILED"
if [ $? != 0 ] ; then 
    echo "Everything PASSED!!"
    exit 0
else
    echo "There are FAILED cases"
    exit 1
fi





