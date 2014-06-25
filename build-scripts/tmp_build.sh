#!/bin/bash 
# temporary build script 
/home/ec2-user/build-scripts/remote_build_new.sh centos6.5_x86_64 192.168.122.2 maxscale.spec . develop
build_result=$?
if [ $build_result -ne 0 ] ; then 
	echo "Build ERROR!"
	exit $build_result
fi

 
/home/ec2-user/build-scripts/remote_build_new.sh centos5.10_x86_64 192.168.122.2 maxscale.spec . develop
build_result=$?
if [ $build_result -ne 0 ] ; then 
	echo "Build ERROR!"
	exit $build_result
fi

 
