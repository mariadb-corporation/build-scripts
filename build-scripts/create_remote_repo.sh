#!/bin/bash

set -x

image=$1
IP=$2
target=$3

#/home/ec2-user/kvm/start_build_VM.sh $image

echo "cleaning $1"
ssh -i /home/ec2-user/KEYS/$image root@$IP -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "rm -rf /home/ec2-user/dest; rm -rf /home/ec2-user/src;"


echo " creating dirs on $1"
ssh -i /home/ec2-user/KEYS/$image ec2-user@$IP -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "mkdir -p /home/ec2-user/dest ; mkdir -p /home/ec2-user/src"

echo "copying stuff to $1"
scp -r -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/pre-repo/$target/$image/* ec2-user@$IP:/home/ec2-user/src/

scp -r -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/MariaDBManager-GPG-KEY.p* ec2-user@$IP:/home/ec2-user/
ssh -i /home/ec2-user/KEYS/$image root@$IP -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  "gpg --import /home/ec2-user/MariaDBManager-GPG-KEY.public"
ssh -i /home/ec2-user/KEYS/$image root@$IP -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no  "gpg --allow-secret-key-import --import /home/ec2-user/MariaDBManager-GPG-KEY.private"


echo "copying create_repo.sh to $1"
scp -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /home/ec2-user/build-scripts/create_repo.sh ec2-user@$IP:/home/ec2-user/

echo "executing create_repo.sh on $1"
ssh -i /home/ec2-user/KEYS/$image root@$IP -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "/home/ec2-user/create_repo.sh /home/ec2-user/dest/ /home/ec2-user/src/"

echo "cleaning /home/ec2-user/repo/$target/$image/"
rm -rf /home/ec2-user/repo/$target/$image/*

echo "copying repo from $image"
mkdir -p /home/ec2-user/repo/$target/$image
scp -r -i /home/ec2-user/KEYS/$1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$IP:/home/ec2-user/dest/* /home/ec2-user/repo/$target/$image/


