#!/bin/bash

# $1 - image
# $2 - target IP
# $3 - ssh key
# $4 - image name

set -x

if [ -f /home/ec2-user/test-machines/lock_$2 ] ; then
	echo "Machine is locked!"
	exit 2
else

	image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$4".img | sed "s/$4.img//" | sed "s/ //g"`
	echo $4 > /home/ec2-user/test-machines/image_name_$2
	echo "image type is $image_type"

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
