#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cmake=$3

if [ -z "$build_dir" ] ; then
        build_dir="/home/ec2-user/workspace/"
fi

cd $build_dir

yum install -y rpmdevtools
yum install -y wget
zypper -n install rpmdevtools
zypper -n install wget
. /home/ec2-user/check_arch.sh

if [[ "$#" != "2" && "$#" != "3" && "$#" != "4" ]]; then
	echo "Not enough arguments, usage"
	echo "./build_rpm.sh path_to_.spec path_to_sources"
	exit 1
fi

yum --version
if [ $? != 0 ] ; then
	zypper -n install rpm-build
	zy=1
else
	yum install -y rpm-build createrepo yum-utils
	zy=0
fi

source_dir=$2;

rm -rf rpmbuild

if [ "$cmake" == "yes" ] ; then
   cmake_cmd="cmake"
   if [ $zy != 0 ] ; then
     zypper -n install gcc gcc-c++ ncurses-devel bison glibc-devel cmake libgcc_s1 perl make libtool libopenssl-devel libaio libaio-devel 
     zypper -n install librabbitmq-devel
     zypper -n install libcurl-devel
     zypper -n install pcre-devel
     cat /etc/*-release | grep "SUSE Linux Enterprise Server 11"
     if [ $? != 0 ] ; then 
       zypper -n install libedit-devel
     fi

     zypper -n install systemtap-sdt-devel
#     zypper -n remove mariadb-*
#     zypper -n --gpg-auto-import-keys --no-gpg-checks install MariaDB-devel MariaDB-client-5.5.41 MariaDB-server 
  wget $mariadbd_link
  tar xzvf $mariadbd_file -C /usr/ --strip-components=1
  cmake_flags+=" -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/ "

#     zypper -n install cmake
   else
     yum clean all 
     yum install -y --skip-broken --nogpgcheck gcc gcc-c++ ncurses-devel bison glibc-devel libgcc perl make libtool openssl-devel libaio libaio-devel librabbitmq-devel libedit-devel
     yum install -y --skip-broken --nogpgcheck libedit-devel
     yum install -y --nogpgcheck libcurl-devel
     yum install -y --nogpgcheck curl-devel
     yum install -y --skip-broken --nogpgcheck systemtap-sdt-devel
     yum install -y --nogpgcheck rpm-sign
     yum install -y --nogpgcheck gnupg
     yum install -y --nogpgcheck pcre-devel
#     yum install -y libaio 
     cat /etc/redhat-release | grep "release 5"
     if [ $? == 0 ] ; then
   	yum install -y --skip-broken --nogpgcheck MariaDB-devel MariaDB-server
     else
     	wget $mariadbd_link
     	tar xzvf $mariadbd_file -C /usr/ --strip-components=1
     	cmake_flags+=" -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/ "
     fi
     cat /etc/redhat-release | grep "release 6"
     rs=$?
     cat /etc/redhat-release | grep "release 5"
     r5=$?
     if [[ $r5 == 0 || $rs == 0 ]] ; then
	echo "cmake is already manually installed"
     else
   	yum install -y --skip-broken $cmake_cmd
     fi
     if [[ $r5 == 0 ]] ; then
        yum remove -y libedit-devel libedit
     fi
   fi
   mkdir _build
   chmod -R a-w .
   chmod u+w _build
   cd _build
  # $cmake_cmd ..  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/
   $cmake_cmd ..  $cmake_flags 
   if [ -d ../coverity ] ; then
	tar xzvf ../coverity/coverity_tool.tgz
	export PATH=$PATH:`pwd`/cov-analysis-linux64-7.6.0/bin/
	cov-build --dir cov-int make
        tar czvf maxscale.tgz cov-int
   else
        make
   fi
 
   make package

  rm ../CMakeCache.txt
  rm CMakeCache.txt


if [ "$BUILD_RABBITMQ" == "yes" ] ; then
  cmake ../rabbitmq_consumer/  $cmake_flags 
  make package
fi

   cd ..
   chmod -R u+wr .
   cp _build/*.rpm .
else

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

	if [ $zy == 0 ] ; then
		rpmbuild -v -bs --nodeps --clean SPECS/$name-${version}-${release}.spec --buildroot $old_pwd/rpm/
		yum clean all
		yum-builddep -y  /home/ec2-user/rpmbuild/SRPMS/$name-${version}-${release}.src.rpm
	else
		build_dep=`rpmbuild -v -ba --clean SPECS/$name-${version}-${release}.spec --buildroot $old_pwd/rpm/ 2>&1 | grep "is needed" | sed "s/is needed by .*$g//" `
		zypper -n install $build_dep
	fi

	# hack to make linking to libmysqld static
	mkdir -p /usr/lib64/dynlib/
	mv /usr/lib64/libmysqld.so*  /usr/lib64/dynlib/

	echo "Building RPM"
	rpmbuild -v -ba --clean SPECS/$name-${version}-${release}.spec --buildroot $old_pwd/rpm/
	if [ $? -ne 0 ]; then
        	echo "RPM build failed"
	        exit 1
	fi
	echo "RPM build is done!"

	cd ../workspace
	cp -r ../rpmbuild .
fi
