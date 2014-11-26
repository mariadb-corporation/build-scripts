#!/bin/bash

image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$image".img | sed "s/$image.img//" | sed "s/ //g"`
echo "image type is $image_type"

if [ "$image_type" != "RPM" ] && [ "$image_type" != "DEB" ] ; then
        echo "unknown image type: should be RPM or DEB"
        exit 1
else
	if [ "$image_type" == "RPM" ] ; then
		/home/ec2-user/test-scripts/build_for_test_rpm.sh
	else
		/home/ec2-user/test-scripts/build_for_test_deb.sh
	fi
fi
