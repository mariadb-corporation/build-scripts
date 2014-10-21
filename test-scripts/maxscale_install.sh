#!/bin/bash

# $1 - image
# $2 - IP
# $3 - target

function check_error() {
        cat $1 | grep "$2"
        if [ $? == 0 ] ; then 
                res=1
                echo "Installation error or warning $2 "
        fi
}  


set -x

image=$1
IP=$2
target=$3

image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$image".img | sed "s/$image.img//" | sed "s/ //g"`
echo "image type is $image_type"

if [ "$image_type" != "RPM" ] && [ "$image_type" != "DEB" ] ; then
        echo "unknown image type: should be RPM or DEB"
        exit 1
else
	if [ "$image_type" == "RPM" ] ; then
		cat /home/ec2-user/test-scripts/maxscale.repo.template | sed "s/###target###/$target/" | sed "s/###image###/$image/" >  /home/ec2-user/test-scripts/maxscale.repo
		scp -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ec2-user/test-scripts/maxscale.repo root@$IP:/etc/yum.repos.d/
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/yum_files/$image/* root@$IP:/etc/yum.repos.d/

		ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP "yum clean all; yum -y install maxscale" 2> inst.err > inst.out
		res=$?
	else
		cat /home/ec2-user/test-scripts/apt_maxscale/$image/maxscale.list | sed "s/###target###/$target/" >  /home/ec2-user/test-scripts/maxscale.list
                scp -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ec2-user/test-scripts/maxscale.list root@$IP:/etc/apt/sources.list.d/
                scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/apt_files/$image/* root@$IP:/etc/apt/sources.list.d/
		ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP "apt-get update; apt-get install -y --force-yes maxscale" 2> inst.err > inst.out
		res=$?
	fi
	echo "stderr from installer:"
	cat inst.err
	echo "stdout from installer:"
	cat inst.err

fi

if [ $res != 0 ] ; then
	echo "error installing maxscale!"
	exit $res
fi

check_error inst.err "failed to create symbolic link"
check_error inst.err "is not a symbolic link"
check_error inst.out "failed to create symbolic link"
check_error inst.out "is not a symbolic link"

if [ $res != 0 ] ; then
        echo "installation errors or warnings!"
        exit $res
fi



scp -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /home/ec2-user/test-scripts/check_maxscale_deps.sh root@$IP:/home/ec2-user/
ssh -i /home/ec2-user/KEYS/$image -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP "/home/ec2-user/check_maxscale_deps.sh"
