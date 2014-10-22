#!/bin/bash

# $1 - Test_name

export Test_name=$1

template_line=`cat /usr/local/skysql/maxscale/system-test/templates | grep $Test_name`
a=( $template_line )
template=${a[1]}


. /usr/local/skysql/maxscale/system-test/set_env_f.sh $replicationIP $galeraIP

echo $template | grep "galera"
if [ $? == 0 ] ; then
	cluster_ip=$galeraIP
else
	cluster_ip=$replicationIP
fi

/usr/local/skysql/maxscale/system-test/configure_maxscale.sh $template $cluster_ip

/usr/local/skysql/maxscale/system-test/$Test_name
res=$?
/home/ec2-user/test-scripts/check_logs.sh
exit $res
