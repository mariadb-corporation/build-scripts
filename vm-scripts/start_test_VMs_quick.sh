#!/bin/bash

# $1 - last digits of IP
# $2 - number of machines

set -x

x=`expr $1 + $2 - 1`
for i in $(seq $1 $x)
do
	image=`cat /home/ec2-user/test-machines/image_name_192.168.122.$1`
#	ssh -i /home/ec2-user/KEYS/$image -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$i "shutdown now"
#        sleep 20
        cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket$i

	mac=`cat /home/ec2-user/kvm/ifcfg/192.168.122.$i/ifcfg-eth1 | grep "HWADDR" | sed "s/HWADDR=//"`
	sudo qemu-system-x86_64 -hda /home/ec2-user/test-machines/test_vm_192.168.122.$i.img -netdev user,id=user.0 -device e1000,netdev=user.0 -boot c  -m 2028 -smp 4 -device e1000,netdev=net0,mac=$mac -netdev tap,id=net0,script=/home/ec2-user/kvm/qemu-ifup --enable-kvm --nographic -qmp unix:/tmp/socket$i,server,nowait &
done

disown

