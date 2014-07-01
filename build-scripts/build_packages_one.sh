#!/bin/bash 
# This scripts is executed on Jenkins machine
# triggers builds for all platform described in "build_machines" file
# $1 - .spec name
# $2 - path to src
# $3 - target 
# $4 - image

set -x

mkdir -p /home/ec2-user/pre-repo/$3/SRC

/home/ec2-user/build-scripts/remote_build_new.sh $4 192.168.122.2 $1 $2 $3
build_result=$?
if [ $build_result -ne 0 ] ; then
        echo "Build ERROR!"
        exit $build_result
fi

