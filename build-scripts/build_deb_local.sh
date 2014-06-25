#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cd /home/ec2-user/workspace

if [ "$#" != "2" ]; then
	echo "Not enough arguments, usage"
	echo "./build_deb_local.sh path_to_.spec path_to_sources"
	exit 1
fi

source_dir=$2;

build_req=`cat "$source_dir/debian/control" | grep "^Build-Depends:" | sed "s/Build-Depends://" | sed "s/([^)]*)//g"`
if [ -n "$build_req" ];then
        echo "installing BuildRequires"
	apt-get update
	apt-get install dpkg-dev 
	apt-get install -y $build_req
        if [ $? -ne 0 ];then
        	echo "Error installing build dependecies, exiting!"
        	exit 1
	fi
fi

dpkg-buildpackage -uc -us
