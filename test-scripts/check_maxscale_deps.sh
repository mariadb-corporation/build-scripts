#!/bin/bash

#set -x 

function check_dep() {
	echo $deps | grep $1
	if [ $? != 0 ] ; then 
		res=1
		echo "Maxscale does NOT depend on $1 "
	fi
}  
function check_dep_neg() {
        echo $deps | grep $1 
        if [ $? == 0 ] ; then 
                res=1  
                echo "Maxscale DOES depend on $1 "
        fi
} 
function check_content_neg() {
        echo $content | grep $1
        if [ $? == 0 ] ; then 
                res=1
                echo "Maxscale DOES contain $1 "
        fi
}  

yum --version
if [ $? == 0 ] ; then
	echo "Using yum to check deps"
	deps=`yum deplist maxscale | grep dependency`
	content=`rpm -ql maxscale`
	rpm -ql maxscale
fi

apt-cache --version
if [ $? == 0 ] ; then
        echo "Using apt-cache to check deps"
        deps=`apt-cache depends maxscale | grep Depends`
	content=`dpkg -L maxscale`
	dpkg -L maxscale
fi

zypper --version
if [ $? == 0 ] ; then
        echo "Using zypper to check deps"
        deps=`zypper info --requires maxscale`
	content=`rpm -ql maxscale`
	rpm -ql maxscale
fi


res=0;

check_dep "libssl"
#check_dep "libz"
#check_dep "libcrypto"
#check_dep "libpthread"
check_dep "libaio"

check_dep_neg "maria"
check_dep_neg "mysql"
check_dep_neg "make"

if [ $res != 0 ] ; then
	echo "Package has wrong dependecy"
fi

#echo $content

check_content_neg "\.a"

exit $res
