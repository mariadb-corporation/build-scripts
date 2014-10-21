#!/bin/bash

# $1 - Test_name

Test_name=$1

template_line=`cat /usr/local/skysql/maxscale/system-test/templates | grep $Test_name`
a=( $template_line )
template=${a[1]}


. /usr/local/skysql/maxscale/system-test/set_env_f.sh $replicationIP $galeraIP

/usr/local/skysql/maxscale/system-test/$Test_name
res=$?
/home/ec2-user/test-scripts/check_logs.sh
exit $res
