#!/bin/bash 
# temporary build script 
/home/ec2-user/repo-build-scripts/create_remote_repo.sh centos6.5_x86_64 192.168.122.2 develop
/home/ec2-user/repo-build-scripts/create_remote_repo.sh centos5.10_x86_64 192.168.122.2 develop
