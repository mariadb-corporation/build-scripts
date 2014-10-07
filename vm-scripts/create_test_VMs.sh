#!/bin/bash

# $1 - image 
# $2 - last digits of IP
# $3 - number of machines
# Do_not_touch_firstVM - yes/no

set -x

image="$1"
IP_end="$2"
N="$3"

if [ "$Do_not_touch_firstVM" == "yes" ] ; then
	N=`expr $N - 1`
	IP_end=`expr $IP_end + 1`
fi

x=`expr $IP_end + $N - 1`
lock=0

sed "s/###IP_end###/$IP_end/"  /home/ec2-user/vm-scripts/generate_hosts.sh.template | sed "s/###N###/$N/" > /home/ec2-user/vm-scripts/generate_hosts.sh
chmod a+x /home/ec2-user/vm-scripts/generate_hosts.sh

for i in $(seq $IP_end $x)
do
        if [ -f /home/ec2-user/test-machines/lock_192.168.122.$i ] ; then
                echo "Machine 192.168.122.$i is locked!"
                lock=1
	fi
done

if [ $lock -eq 1 ] ; then 
	exit 2
else 
	/home/ec2-user/vm-scripts/stop_test_VMs.sh $IP_end $N
	for i in $(seq $IP_end $x)
	do
		cp  /home/ec2-user/kvm/images/$image.img /home/ec2-user/test-machines/test_vm_192.168.122.$i.img
		/home/ec2-user/vm-scripts/create_VM.sh /home/ec2-user/test-machines/test_vm_192.168.122.$i.img 192.168.122.$i /home/ec2-user/KEYS/$image $image
	done
	/home/ec2-user/vm-scripts/start_test_VMs_quick.sh $IP_end $N
	/home/ec2-user/vm-scripts/wait_for_test_vm.sh $image $IP_end
fi
