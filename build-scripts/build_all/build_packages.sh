#!/bin/bash 
# This scripts is executed on Jenkins machine
# triggers builds for all platform described in "build_machines" file
# $1 - .spec name
# $2 - path to src
# $3 - target 

set -x

# /home/ec2-user/kvm/check_build_VMs.sh
mkdir -p /home/ec2-user/pre-repo/$3/SRC
build_machines="/home/ec2-user/build-scripts/build_machines"

echo "#!/bin/bash " >  /home/ec2-user/build-scripts/tmp_build.sh
echo "# temporary build script " >>  /home/ec2-user/build-scripts/tmp_build.sh

cat $build_machines | grep "Active:" | while read Line; do 
	aLine=( $Line )
	img=${aLine[1]}
	IP=${aLine[2]}

        echo "img="$img
        echo "IP="$IP

	if [ -z "${img[$i]}" ] || [ -z "${IP[$i]}" ] ; then 
		echo "error parcing 'build_machines' file"
		exit 1
	fi
	echo "/home/ec2-user/build-scripts/remote_build_new.sh $img $IP $1 $2 $3" >>   /home/ec2-user/build-scripts/tmp_build.sh
	cat /home/ec2-user/build-scripts/check_build >>  /home/ec2-user/build-scripts/tmp_build.sh
done

chmod a+x /home/ec2-user/build-scripts/tmp_build.sh

/home/ec2-user/build-scripts/tmp_build.sh

