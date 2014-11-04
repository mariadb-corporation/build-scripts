#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cmake=$3

if [ -z "$build_dir" ] ; then
        build_dir="/home/ec2-user/workspace/"
fi


cd $build_dir



apt-get update
apt-get install -y dpkg-dev

if [ "$cmake" == "yes" ] ; then
  cat /etc/*-release | grep "Ubuntu"
#  if [ $? = 0 ]; then
#	apt-get remove -y --force-yes locales language-pack-en-base language-pack-en ubuntu-minimal
#  fi
  apt-get install -y --force-yes cmake
  apt-get install -y --force-yes gcc g++ ncurses-dev bison build-essential libssl-dev libaio-dev perl make libtool librabbitmq-dev

  apt-get install -y --force-yes libmariadbclient-dev libmariadbd-dev mariadb-server
#  apt-get install -y --force-yes libmariadb-client-lgpl-dev libmariadbd-dev mariadb-server

#  cmake . --debug-output $cmake_flags

#  make
#  make package

  mkdir _build
  chmod -R a-w .
  chmod u+w _build
  cd _build
  cmake ..  $cmake_flags
   if [ -d ../coverity ] ; then
        tar xzvf ../coverity/cov-analysis-linux*.tar.gz
        export PATH=$PATH:`pwd`/cov-analysis-linux64-7.5.0/bin/
        cov-build --dir cov-int make
        tar czvf maxscale.tgz cov-int
   else
        make
   fi

  make package

  cp _CPack_Packages/Linux/DEB/*.deb ../
  cd ..
  chmod -R u+wr .
  cp _build/*.deb .
else
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
  mkdir -p /usr/lib/x86_64-linux-gnu/dynlib
  mv /usr/lib/x86_64-linux-gnu/libmysqld.so* /usr/lib/x86_64-linux-gnu/dynlib/
  dpkg-buildpackage -uc -us
fi
