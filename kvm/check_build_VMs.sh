#!/bin/bash
ping 192.168.122.182 -c 1
res=$?
ping 192.168.122.191 -c 1
res=$(($res + $?))
ping 192.168.122.190 -c 1
res=$(($res + $?))
#ping 192.168.122.151 -c 1
#res=$(($res + $?))
#ping 192.168.122.150 -c 1
#res=$(($res + $?))



if [ $res -gt 0 ] ; then
	/home/ec2-user/kvm/stop_build_VM.sh
	sleep 30
	/home/ec2-user/kvm/start_build_VMs.sh
	sleep 60
fi


