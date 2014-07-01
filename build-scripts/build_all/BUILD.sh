#!/bin/bash

# $1 - TAG, BRANCH, COMMIT
# $2 - tag or branch name or commit ID
# $3 - target repository name

set -x

source=$1
value=$2
target=Â$3
target=`echo $target | tr -cd "[:print:]" `
echo "target $target"

num_of_specs=`ls -1 *.spec | wc -l`
if [ $num_of_specs -ne 1 ]; then
        echo "Error there is no or several .spec. Exiting"
        exit 1
fi
spec_name=`ls *.spec`
package_name=`echo ${spec_name%.*}`

if [ "$source" == "TAG" ] ; then
	git reset --hard $tag-$value
fi

if [ "$source" == "BRANCH" ] ; then
	git branch $value origin/$value
        git checkout $value
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

/home/ec2-user/build-scripts/build_packages.sh $spec_name . $target 

