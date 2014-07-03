#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cd /home/ec2-user/workspace

if [ -f  /home/ec2-user/parameters ]; then
	. /home/ec2-user/parameters
fi

if [ "$#" != "2" ]; then
	echo "Not enough arguments, usage"
	echo "./build_rpm.sh path_to_.spec path_to_sources"
	exit 1
fi

yum install -y rpm-build createrepo yum-utils

source_dir=$2;

rm -rf rpmbuild

version=`cat  "$1" | sed -ne 's/^%define version\s*\([^\s]*\)$/\1/p' | sed 's/ //'`
release=`cat  "$1" | sed -ne 's/^%define release\s*\([^\s]*\)$/\1/p' | sed 's/ //'`

name=`cat  "$1" | sed -ne 's/^%define name\s*//p'  | sed 's/ //'`

if [ -z "$version" ];then
	echo "Version in $1 is incorrect, exiting!"
	exit 1
fi

if [ -z "$name" ];then
        echo "Package name in $1 is incorrect, exiting!"
        exit 1
fi

echo "name:"$name":"
echo "version:"$version":"
echo "release:"$release":"

#build_req=`cat "$1" | grep "^BuildRequires:" | sed "s/BuildRequires://"`
#if [ -n "$build_req" ];then
#        echo "installing BuildRequires: $build_req"
#	yum clean all
#	yum install -y $build_req
#        if [ $? -ne 0 ];then
#        	echo "Error installing build dependecies, exiting!"
#        	exit 1
#	fi
#fi
#yum clean all
#yum-builddep -y $1

cd ..
rm -rf rpmbuild
mkdir -p rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
if [ $? -ne 0 ]; then
	echo "Can't create directories for RPM build"
	exit 1
fi

#tar -zcvf rpmbuild/SOURCES/${name}-${version}-${release}.tar.gz  workspace/* --transform s/workspace/${name}-${version}/
mv workspace ${name}-${version}
tar -zcvf rpmbuild/SOURCES/${name}-${version}-${release}.tar.gz  ${name}-${version}/* 
mv ${name}-${version} workspace


if [ $? -ne 0 ]; then
        echo "tar failed to create source tarball"
        exit 1
fi

cd workspace

cp "$1" ../rpmbuild/SPECS/$name-${version}-${release}.spec
if [ $? -ne 0 ]; then
        echo "Can't copy .spec"
        exit 1
fi

old_pwd=`pwd`
rm -rf rpm
cd ../rpmbuild/
rpmbuild -v -bs --nodeps --clean SPECS/$name-${version}-${release}.spec --buildroot $old_pwd/rpm/
yum clean all
yum-builddep -y  /home/ec2-user/rpmbuild/SRPMS/$name-${version}-${release}.src.rpm

# hack to make linking to libmysqld static
rm /usr/lib64/libmysqld.so.18
rm /usr/lib64/libmysqld.so

echo "Building RPM"
rpmbuild -v -ba --clean SPECS/$name-${version}-${release}.spec --buildroot $old_pwd/rpm/
if [ $? -ne 0 ]; then
        echo "RPM build failed"
        exit 1
fi
echo "RPM build is done!"

cd ../workspace
cp -r ../rpmbuild .
