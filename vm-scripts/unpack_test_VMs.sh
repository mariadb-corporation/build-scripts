#!/bin/bash

# $1 - archive name

set -x 

archive=$1
tar_out=`tar tzf  /home/ec2-user/vm-archives/$archive.tar.gz`
if [ $? -ne 0 ] ; then
	echo "Error accessing archive"
	exit 1
fi

list=`echo $tar_out | grep "test_vm_192.168.122." | sed "s/test_vm_192.168.122.//g" | sed "s/.img//g" `

for i in $list
do
        cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$i
done

sleep 20
cd /home/ec2-user/test-machines/
tar xzvf /home/ec2-user/vm-archives/$archive.tar.gz
