. /home/ec2-user/kvm/qemu_cmd.sh
sudo $qemu_cmd -hda $1 -netdev user,id=user.0 -device e1000,netdev=user.0 -boot c  -m 2028 -device e1000,netdev=net0,mac=DE:AD:BE:EF:4A:02 -netdev tap,id=net0,script=/home/ec2-user/kvm/qemu-ifup --nographic -qmp unix:/tmp/socket002,server,nowait &

