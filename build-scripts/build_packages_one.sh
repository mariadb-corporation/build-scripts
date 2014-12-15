#!/bin/bash 
# This scripts is executed on Jenkins machine
# triggers builds for all platform described in "build_machines" file
# $1 - .spec name
# $2 - path to src
# $3 - target 
# $4 - image
# $5 - cmake (yes/no)

set -x

mkdir -p /home/ec2-user/pre-repo/$3/SRC

IP="$BuildIP"
if [ -z $IP ] ; then
	IP="192.168.122.2"
fi

/home/ec2-user/build-scripts/remote_build_new.sh $4 $IP $1 $2 $3 $5
build_result=$?

shellcheck `find . | grep "\.sh"` | grep -i "POSIX sh"
if [ $? -eq 0 ] ; then
	echo "POSIX sh error are found in the scripts, exiting"
	exit 1
fi

if [ $build_result -ne 0 ] ; then
        echo "Build ERROR!"
        exit $build_result
fi

