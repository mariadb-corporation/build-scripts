#!/bin/bash

# $1 - Test_name

set -x
export Test_name=$1

. /usr/local/skysql/maxscale/system-test/set_env_f.sh $replicationIP $galeraIP

/usr/local/skysql/maxscale/system-test/configure_maxscale.sh

/usr/local/skysql/maxscale/system-test/$Test_name
res=$?
/home/ec2-user/test-scripts/check_logs.sh
exit $res
