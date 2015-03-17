#!/bin/bash

cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket2
cat /home/ec2-user/kvm/f | sudo socat STDIO UNIX-CONNECT:/tmp/socket002

. /home/ec2-user/kvm/qemu_cmd.sh
sleep 10

cp /home/ec2-user/kvm/images/$1.img /home/ec2-user/kvm/build_VMs/

sudo $qemu_cmd -hda /home/ec2-user/kvm/build_VMs/$1.img  -netdev user,id=user.0 -device e1000,netdev=user.0 -boot c  -m 2028 -device e1000,netdev=net0,mac=DE:AD:BE:EF:4A:02 -netdev tap,id=net0,script=/home/ec2-user/kvm/qemu-ifup --nographic -qmp unix:/tmp/socket002,server,nowait &

x=1
while [  "$x" -ne 0 ]; do
       echo "Tryng ssh to 192.168.122.2"  
       ssh -i /home/ec2-user/KEYS/$1 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 'ls > /dev/null'
       x=$?
done
sleep 10
ssh-keygen -f "/home/ec2-user/.ssh/known_hosts" -R 192.168.122.2

disown
