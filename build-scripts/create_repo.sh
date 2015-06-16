#!/bin/bash

set -x

destdir=$1
sourcedir=$2

arch="binary-amd64"
uname -m | grep "x86_64"
if [ $? -ne 0 ] ; then
	arch="binary-ppc64el"
fi

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
        echo $ubuntu_ver | grep "14.10"
        if [ $? -eq 0 ]; then
                dist_name="utopic";
        fi

	if [ -z "$dist_name" ]; then
		dist_name="unknown"
	fi
	mkdir -p dists/$dist_name/main/$arch/
	cp $sourcedir/* dists/$dist_name/main/$arch/
	apt-get update
	apt-get install -y dpkg-dev
	dpkg-scanpackages dists/$dist_name/main/$arch/  /dev/null | gzip -9c > dists/$dist_name/main/$arch/Packages.gz
	gunzip -c dists/$dist_name/main/$arch/Packages.gz > dists/$dist_name/main/$arch/Packages
#	echo "Archive: main" > dists/$dist_name/main/$arch/Release
#	echo "Suite: main" >> dists/$dist_name/main/$arch/Release
	echo "Components: main" >> dists/$dist_name/main/$arch/Release
	echo "Codename: $dist_name" >> dists/$dist_name/main/$arch/Release
	echo "Origin: MariaDB" >> dists/$dist_name/main/$arch/Release
	echo "Label: MariaDB Maxscale repository" >> dists/$dist_name/main/$arch/Release
	uname -m | grep "x86_64"
	if [ $? -eq 0 ] ; then
 		echo "Architectures: amd64 i386" >> dists/$dist_name/main/$arch/Release
		mkdir -p dists/$dist_name/main/binary-i386/
		dpkg-scanpackages dists/$dist_name/main/binary-i386/  /dev/null | gzip -9c > dists/$dist_name/main/binary-i386/Packages.gz
	        gunzip -c dists/$dist_name/main/binary-i386/Packages.gz > dists/$dist_name/main/binary-i386/Packages
	else 
		 echo "Architectures: ppc64el" >> dists/$dist_name/main/$arch/Release
	fi
	echo "Description:  MariaDB MaxScale" >> dists/$dist_name/main/$arch/Release
	cp dists/$dist_name/main/$arch/Release dists/$dist_name/Release
#	cp dists/$dist_name/main/$arch/Packages.gz dists/$dist_name
	apt-ftparchive release dists/$dist_name/ >> dists/$dist_name/Release

	gpg -abs -o  dists/$dist_name/Release.gpg dists/$dist_name/Release 
else
# RPM-based system
	yum install -y createrepo
	zypper -n remove patterns-openSUSE-minimal_base-conflicts
	zypper -n install createrepo
	echo "%_signature gpg" >> ~/.rpmmacros
	echo "%_gpg_name  MariaDBManager" >>  ~/.rpmmacros
	rpm --resign $sourcedir/*.rpm
	gpg --output repomd.xml.key --sign $sourcedir/repodata/repomd.xml
	cp $sourcedir/* $destdir/
	pushd ${destdir} >/dev/null 2>&1
	    createrepo -d -s sha .
	popd >/dev/null 2>&1
	gpg -a --detach-sign $destdir/repodata/repomd.xml
#	cp repomd.xml.key $destdir/repodata/
	
fi
