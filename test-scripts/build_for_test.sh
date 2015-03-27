#!/bin/bash

export maxdir="/usr/local/mariadb-maxscale"

image_type=`cat /home/ec2-user/kvm/images/image_type | grep "$image".img | sed "s/$image.img//" | sed "s/ //g"`
echo "image type is $image_type"

#build_name="$image_$MariaDBVersion"
#export cmake_flags="$cmake_flags -DCTEST_BUILD_NAME=$build_name"

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

ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@$BuildIP  "mkdir -p $maxdir/Binlog_Service"
