#!/bin/bash

# $1 - TAG, BRANCH, COMMIT
# $2 - tag or branch name or commit ID
# $3 - target repository name
# $4 - image
# $5 - alternative dir

set -x

source=$1
value=$2
target=Â$3
image=$4
target=`echo $target | tr -cd "[:print:]" `
echo "target $target"

if [ "$source" == "TAG" ] ; then
	git reset --hard $value
fi

if [ "$source" == "BRANCH" ] ; then
	git branch $value origin/$value
        git checkout $value
	git pull
       	if [ $? -ne 0 ] ; then
		echo "Error checkout branch $branch"
                exit 12
        fi
fi

if [ "$source" == "COMMIT" ] ; then
	git reset --hard $value
        if [ $? -ne 0 ] ; then
       	        echo "Error resetting tree to the commit $value"
               	exit 12
        fi
fi

commitID=`git log | head -1 | sed "s/commit //"`
echo "commitID $commitID"

if [ "$5" != "" ] ; then
  cd $5
fi

spec_name="foo.spec"
if [ "$cmake" != "yes" ] ; then
	num_of_specs=`ls -1 *.spec | wc -l`
	if [ $num_of_specs -ne 1 ]; then
	        echo "Error there is no or several .spec. Exiting"
        	exit 1
	fi
	spec_name=`ls *.spec`
	package_name=`echo ${spec_name%.*}`
fi

if [ "$gcov" == "yes" ] ; then
	export cmake_flags="$cmake_flags -DGCOV=Y"
fi

if [ "$BUILD_TEST" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DBUILD_TESTS=Y"
fi

if [ "$DEBUG" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DBUILD_TYPE=Debug"
fi

if [ "$BUILD_RABBITMQ" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DBUILD_RABBITMQ=Y"
else
	export cmake_flags="$cmake_flags -DBUILD_RABBITMQ=N"
fi

if [ "$Dynlib" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DSTATIC_EMBEDDED=N"
else
       export cmake_flags="$cmake_flags -DSTATIC_EMBEDDED=Y"
fi

export cmake_flags="$cmake_flags  -DPACKAGE=Y"
/home/ec2-user/build-scripts/build_packages_one.sh $spec_name . $target $image $cmake
res=$?

sudo killall openconnect
exit $res
