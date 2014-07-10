#/bin/bash
for i in $(seq 121 199)
do
	mkdir -p /home/ec2-user/kvm/ifcfg/192.168.122.$i
	mkdir -p /home/ec2-user/kvm/interfaces/192.168.122.$i
	cp ifcfg-eth0 /home/ec2-user/kvm/ifcfg/192.168.122.$i/
	cp ifcfg-eth1 /home/ec2-user/kvm/ifcfg/192.168.122.$i/
	cp interfaces /home/ec2-user/kvm/interfaces/192.168.122.$i/
	IP=`echo $i`
#	echo $IP
	sed -i "s/###IP###/$IP/" /home/ec2-user/kvm/ifcfg/192.168.122.$i/ifcfg-eth1
	sed -i "s/###IP###/$IP/" /home/ec2-user/kvm/interfaces/192.168.122.$i/interfaces
	mac_dec=`expr $i - 100`
	mac=`printf '%x' $mac_dec`
#	echo $mac
	sed -i "s/###mac###/$mac/" /home/ec2-user/kvm/ifcfg/192.168.122.$i/ifcfg-eth1
done
