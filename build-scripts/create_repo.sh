#!/bin/bash

set -x

destdir=$1
sourcedir=$2
rm -rf $destdir
mkdir -p  $destdir/

zypper --version
z_res=$?
yum --version
y_res=$?

if [ $z_res -eq 127 ] && [ $y_res -eq 127 ] ; then
# DEB-based system
	cd $destdir
	debian_ver=`cat /etc/debian_version`
	echo "Debian version: $debina_ver"
	dist_name=""
	echo $debian_ver  | grep "6.0.7"
	if [ $? -eq 0 ]; then
		dist_name="squeeze";
	fi
	echo $debian_ver  | grep "7.4"
        if [ $? -eq 0 ]; then
                dist_name="wheezy";
        fi
	ubuntu_ver=`cat /etc/os-release | grep "VERSION_ID"`
	echo $ubuntu_ver | grep "12.04"
        if [ $? -eq 0 ]; then
                dist_name="precise";
        fi
        echo $ubuntu_ver | grep "14.04"
        if [ $? -eq 0 ]; then
                dist_name="trusty";
        fi

        echo $ubuntu_ver | grep "13.10"
        if [ $? -eq 0 ]; then
                dist_name="saucy";
        fi

	if [ -z "$dist_name" ]; then
		dist_name="unknown"
	fi
	mkdir -p dists/$dist_name/main/binary-amd64/
	cp $sourcedir/* dists/$dist_name/main/binary-amd64/
	apt-get update
	apt-get install -y dpkg-dev
	dpkg-scanpackages dists/$dist_name/main/binary-amd64/  /dev/null | gzip -9c > dists/$dist_name/main/binary-amd64/Packages.gz
	gunzip -c dists/$dist_name/main/binary-amd64/Packages.gz > dists/$dist_name/main/binary-amd64/Packages
#	echo "Archive: main" > dists/$dist_name/main/binary-amd64/Release
#	echo "Suite: main" >> dists/$dist_name/main/binary-amd64/Release
	echo "Components: main" >> dists/$dist_name/main/binary-amd64/Release
	echo "Codename: $dist_name" >> dists/$dist_name/main/binary-amd64/Release
	echo "Origin: SkySQL" >> dists/$dist_name/main/binary-amd64/Release
	echo "Label: SkySQL MariaDB-Manager repository" >> dists/$dist_name/main/binary-amd64/Release
	echo "Architectures: amd64" >> dists/$dist_name/main/binary-amd64/Release
	echo "Description:  SkySQL MariaDB-Manager" >> dists/$dist_name/main/binary-amd64/Release
	cp dists/$dist_name/main/binary-amd64/Release dists/$dist_name/Release
#	cp dists/$dist_name/main/binary-amd64/Packages.gz dists/$dist_name
	apt-ftparchive release dists/$dist_name/ >> dists/$dist_name/Release

	gpg -abs -o  dists/$dist_name/Release.gpg dists/$dist_name/Release 
else
# RPM-based system
	yum install -y createrepo
	zypper -n install createrepo
	echo "%_signature gpg" >> ~/.rpmmacros
	echo "%_gpg_name  MariaDBManager" >>  ~/.rpmmacros
	rpm --resign $sourcedir/*.rpm
	cp $sourcedir/* $destdir/
	pushd ${destdir} >/dev/null 2>&1
	    createrepo -d -s sha .
	popd >/dev/null 2>&1
	
fi
