#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cd /home/ec2-user/workspace

apt-get update
apt-get install -y dpkg-dev

build_req=`dpkg-checkbuilddeps  2>&1 | grep "Unmet build dependencies" | sed "s/dpkg-checkbuilddeps: Unmet build dependencies: //" | sed "s/([^)]*)//g"`

if [ -n "$build_req" ];then
        echo "installing BuildRequires $build_req"
#	apt-get update
	apt-get install -y dpkg-dev 
	#devscripts
	#echo "y" | mk-build-deps --install $source_dir/debian/control
	apt-get install -y --force-yes $build_req
        if [ $? -ne 0 ];then
        	echo "Error installing build dependecies, exiting!"
        	exit 1
	fi
fi
rm /usr/lib/x86_64-linux-gnu/libmysqld.so
rm /usr/lib/x86_64-linux-gnu/libmysqld.so.18
dpkg-buildpackage -uc -us
