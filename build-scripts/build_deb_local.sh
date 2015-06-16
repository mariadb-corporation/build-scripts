#!/bin/bash 

# do the real building work
# this script is executed on build VM

set -x

cmake=$3

if [ -z "$build_dir" ] ; then
        build_dir="/home/ec2-user/workspace/"
fi


cd $build_dir

. /home/ec2-user/check_arch.sh

apt-get update
apt-get install -y dpkg-dev

if [ "$cmake" == "yes" ] ; then
  cat /etc/*-release | grep "Ubuntu"
#  if [ $? = 0 ]; then
#	apt-get remove -y --force-yes locales language-pack-en-base language-pack-en ubuntu-minimal
#  fi
  apt-get install -y --force-yes cmake
  apt-get install -y --force-yes gcc g++ ncurses-dev bison build-essential libssl-dev libaio-dev perl make libtool 
  apt-get install -y --force-yes librabbitmq-dev
  apt-get install -y --force-yes libcurl4-openssl-dev
  apt-get install -y --force-yes libpcre3-dev

  wget --retry-connrefused $mariadbd_link
  tar xzvf $mariadbd_file -C /usr/ --strip-components=1

#  cmake . --debug-output $cmake_flags

#  make
#  make package

  mkdir _build
  chmod -R a-w .
  chmod u+w _build
  cd _build
  cmake ..  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/
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
  cmake ../rabbitmq_consumer/  $cmake_flags -DERRMSG=/usr/share/english/errmsg.sys -DEMBEDDED_LIB=/usr/lib/
  make package
fi

  cp _CPack_Packages/Linux/DEB/*.deb ../
  cd ..
  chmod -R u+wr .
  cp _build/*.deb .
  cp *.deb ..
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
