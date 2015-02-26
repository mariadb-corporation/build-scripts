#!/bin/bash

# $1 - Test_name

#set -x
export Test_name=$1

if [ "$remote_test_machine" == "yes" ] ; then
	key=`cat /home/ec2-user/test-machines/image_name_$test_machine_ip`

	scp -i /home/ec2-user/KEYS/$key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-scripts/run_system_test_local.sh root@$test_machine_ip:/root/ 

	scp -i /home/ec2-user/KEYS/$key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/KEYS root@$test_machine_ip:/home/ec2-user/
	ssh -i /home/ec2-user/KEYS/$key  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$test_machine_ip "mkdir /home/ec2-user/test-machines/"
	scp -i /home/ec2-user/KEYS/$key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/test-machines/image_name_* root@$test_machine_ip:/home/ec2-user/test-machines/
	scp -i /home/ec2-user/KEYS/$key -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$test_machine_ip "chown ec2-user:ec2-user -R /home/ec2-user/*"




	ssh -i /home/ec2-user/KEYS/$key  -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$test_machine_ip /root/run_system_test_local.sh $Test_name $replicationIP $galeraIP
 	res=$?
else

	. /usr/local/skysql/maxscale/system-test/set_env_f.sh $replicationIP $galeraIP

#	/usr/local/skysql/maxscale/system-test/configure_maxscale.sh

	/usr/local/skysql/maxscale/system-test/$Test_name
	res=$?
fi


/home/ec2-user/test-scripts/check_logs.sh
exit $res
