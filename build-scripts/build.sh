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
	git reset --hard $tag-$value
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

# checking .spec for ##VERSION_TAG## and replacing it with info from tag
grep "##VERSION_TAG##" $spec_name > /dev/null
if [ $? -eq 0 ]; then
       	echo "Put version number into .spec"
        mv $spec_name tmp1.spec
       	sed "s/##VERSION_TAG##/0.7/" tmp1.spec > $spec_name
        rm tmp1.spec
else
       	echo "##VERSION_TAG## is not found. .spec unchanged"
fi

# checking .spec for ##RELEASE_TAG## and replacing it with info from tag
grep "##RELEASE_TAG##" $spec_name > /dev/null
if [ $? -eq 0 ]; then
       	echo "Put release number into .spec"
        mv $spec_name tmp1.spec   
       	sed "s/##RELEASE_TAG##/1/" tmp1.spec > $spec_name
        rm tmp1.spec
else
       	echo "##RELEASE_TAG## is not found. .spec unchanged"
fi

fi

#if [ "$gcov" == "yes" ] ; then
#	patch -p1 < gcov.diff
#fi

if [ "$gcov" == "yes" ] ; then
	export cmake_flags="-DGCOV=Y"
fi

if [ "$BUILD_TEST" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DBUILD_TESTS=Y"
fi

if [ "$DEBUG" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DBUILD_TYPE=Debug"
fi

if [ "$BUILD_RABBITMQ" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DBUILD_RABBITMQ=Y"
fi

if [ "$Dynlib" == "yes" ] ; then
        export cmake_flags="$cmake_flags -DSTATIC_EMBEDDED=N"
else
       export cmake_flags="$cmake_flags -DSTATIC_EMBEDDED=Y"
fi



/home/ec2-user/build-scripts/build_packages_one.sh $spec_name . $target $image $cmake

