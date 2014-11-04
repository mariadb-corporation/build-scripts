#!/bin/bash

# $1 - image
# $2 - target IP
# $3 - ssh key
# $4 - image name

set -x

IP=$2

if [ -f /home/ec2-user/test-machines/lock_$2 ] ; then
	echo "Machine is locked!"
	exit 2
else

	image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$4".img | sed "s/$4.img//" | sed "s/ //g"`
	echo $4 > /home/ec2-user/test-machines/image_name_$2
	echo "image type is $image_type"

	echo "Checking process list for qemu processes with $IP"
	PIDs=`ps ax | grep "$IP" | grep qemu | sed -e 's/^[ \t]*//' | cut -d' ' -f1`
	echo $PIDs
	for PID in $PIDs; do
        	echo "Killing process $PID"
	        sudo kill $PID
	done


	if [ "$image_type" != "RPM" ] && [ "$image_type" != "DEB" ] ; then
        	echo "unknown image type: should be RPM or DEB"
	        exit 1
	else 
		if [ "$image_type" != "DEB" ] ; then
			/home/ec2-user/vm-scripts/create_VM_RPM.sh $*
		else 
			/home/ec2-user/vm-scripts/create_VM_DEB.sh $*
		fi
	fi
fi
