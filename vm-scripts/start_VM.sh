#!/bin/bash

# $1 - last digits of IP

set -x

. /home/ec2-user/kvm/qemu_cmd.sh

image=`cat /home/ec2-user/test-machines/image_name_192.168.122.$1`
ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$1 "shutdown now"
sleep 20
cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$1
sleep 10
echo "Killing qemu processes for 192.168.122.$1"
PIDs=`ps ax | grep "192.168.122.$1" | grep qemu | sed -e 's/^[ \t]*//' | cut -d' ' -f1`
for PID in $PIDs ; do
	echo "Killing process $PID"
	sudo kill $PID
done


mac=`cat /home/ec2-user/kvm/ifcfg/192.168.122.$1/ifcfg-eth1 | grep "HWADDR" | sed "s/HWADDR=//"`
sudo $qemu_cmd -hda /home/ec2-user/test-machines/test_vm_192.168.122.$1.img -netdev user,id=user.0 -device e1000,netdev=user.0 -boot c  -m 2028 -device e1000,netdev=net0,mac=$mac -netdev tap,id=net0,script=/home/ec2-user/kvm/qemu-ifup --nographic -qmp unix:/tmp/socket$i,server,nowait 2> /dev/null > /dev/null &

disown

