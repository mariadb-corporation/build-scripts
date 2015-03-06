#!/bin/bash

# $1 - test_name

set -x
export test_name=$1
replicationIP=$2
galeraIP=$3

. /usr/local/skysql/maxscale/system-test/set_env_f.sh $replicationIP $galeraIP

/usr/local/skysql/maxscale/system-test/configure_maxscale.sh

/usr/local/skysql/maxscale/system-test/$test_name
