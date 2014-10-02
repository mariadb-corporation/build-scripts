#!/bin/bash

# this script copyies stuff to VM and run build on VM

# $1 - image
# $2 - IP
# $3 - .spec name
# $4 - path to src
# $5 - target 
# $6 - cmake

set -x

image=$1
IP=$2
target=$5

echo "target is $target"
mkdir -p /home/ec2-user/pre-repo/$target/SRC
mkdir -p /home/ec2-user/pre-repo/$target/$image

/home/ec2-user/kvm/start_build_VM.sh $image

echo "copying stuff to $image machine"
echo "scp  -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r ./* ec2-user@$IP:/home/ec2-user/workspace"
ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP 'mkdir -p /home/ec2-user/workspace'

scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r  ./* ec2-user@$IP:/home/ec2-user/workspace

if [ $?	-ne 0 ] ; then
        echo "Error copying stuff to $image machine"
        exit 2
fi

orig_image=$image
echo "image: $image"
image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$orig_image".img | sed "s/$orig_image.img//" | sed "s/ //g"`
echo "image type is $image_type"

if [ "$image_type" != "RPM" ] && [ "$image_type" != "DEB" ] ; then
        echo "unknown image type: should be RPM or DEB"
        exit 1
else
	if [ "$image_type" == "RPM" ] ; then

		echo "copying build script to $image machine"
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/yum_files/$image/* root@$IP:/etc/yum.repos.d/
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/vm_setup_scripts/$image.sh root@$IP:/home/ec2-user/
		ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP /home/ec2-user/$image.sh

		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/build-scripts/build_rpm_local.sh  ec2-user@$IP:/home/ec2-user/
		if [ $? -ne 0 ] ; then
		        echo "Error copying build scripts to $image machine"
		        exit 3
		fi

		echo "run build on $image"
		ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  root@$IP /home/ec2-user/build_rpm_local.sh $3 $4 $6 $cmake_flags
		if [ $? -ne 0 ] ; then
		        echo "Error build on $image"
		        exit 4
		fi

		echo "copying repo to the repo/$target/$image"
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP:/home/ec2-user/rpmbuild/RPMS/noarch/* /home/ec2-user/pre-repo/$target/$image
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP:/home/ec2-user/rpmbuild/RPMS/i386/* /home/ec2-user/pre-repo/$target/$image
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP:/home/ec2-user/rpmbuild/RPMS/x86_64/* /home/ec2-user/pre-repo/$target/$image
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP:/home/ec2-user/workspace/*.rpm /home/ec2-user/pre-repo/$target/$image
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP:/home/ec2-user/rpmbuild/SOURCES/* /home/ec2-user/pre-repo/$target/SRC
	else
                echo "copying build script to $image machine"
		scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/apt_files/$image/* root@$IP:/etc/apt/sources.list.d/

                scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/vm_setup_scripts/$image.sh root@$IP:/home/ec2-user/
                ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$IP /home/ec2-user/$image.sh

                scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -r /home/ec2-user/build-scripts/build_deb_local.sh  ec2-user@$IP:/home/ec2-user/
                if [ $? -ne 0 ] ; then
                        echo "Error copying build scripts to $image machine"
                        exit 3
                fi

                echo "run build on $image"
                ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  root@$IP /home/ec2-user/build_deb_local.sh $3 $4 $6
                if [ $? -ne 0 ] ; then
                        echo "Error build on $image"
                        exit 4
                fi
                echo "copying repo to the repo/$target/$image"
                mkdir -p /home/ec2-user/pre-repo/$target/$image
                scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP:/home/ec2-user/*.deb /home/ec2-user/pre-repo/$target/$image
		echo "copying grex from /home/ec2-user/pre-repo/$target/$image/"
	fi
fi

echo "package building for $target done!"

/home/ec2-user/build-scripts/create_remote_repo.sh $image 192.168.122.2 $target
