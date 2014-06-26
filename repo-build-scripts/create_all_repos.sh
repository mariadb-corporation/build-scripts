#!/bin/bash
# $1 - target 

set -x

target=$1

echo "#!/bin/bash " >  /home/ec2-user/repo-build-scripts/tmp_build.sh
echo "# temporary build script " >>  /home/ec2-user/repo-build-scripts/tmp_build.sh

cat /home/ec2-user/build-scripts/build_machines | grep "Active:" | while read Line; do 
        aLine=( $Line )
        img=${aLine[1]}
        IP=${aLine[2]}
        if [ -z "$img" ] || [ -z "$IP" ] ; then 
                echo "error parcing 'build_machines' file"
                exit 1
        fi
        echo "building repository for:"
        echo "img="$img
        echo "IP="$IP
       	echo "/home/ec2-user/repo-build-scripts/create_remote_repo.sh $img $IP $target"  >>  /home/ec2-user/repo-build-scripts/tmp_build.sh
done

chmod a+x /home/ec2-user/repo-build-scripts/tmp_build.sh

/home/ec2-user/repo-build-scripts/tmp_build.sh
