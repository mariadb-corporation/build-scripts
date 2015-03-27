#!/bin/bash

# $1 - test_name

set -x
export test_name=$1
replicationIP=$2
galeraIP=$3

. set_env.sh $replicationIP $galeraIP

ctest -VV -R $test_name
