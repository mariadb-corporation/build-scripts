#/bin/bash
for i in $(seq 100 199)
do
	mkdir -p /home/ec2-user/kvm/ifcfg-fedora/192.168.122.$i
	cp ifcfg-ens3 /home/ec2-user/kvm/ifcfg-fedora/192.168.122.$i/
	cp ifcfg-ens4 /home/ec2-user/kvm/ifcfg-fedora/192.168.122.$i/
	IP=`echo $i`
#	echo $IP
	sed -i "s/###IP###/$IP/" /home/ec2-user/kvm/ifcfg-fedora/192.168.122.$i/ifcfg-ens4
	mac_dec=`expr $i - 100`
	mac=`printf '%x' $mac_dec`
#	echo $mac
	sed -i "s/###mac###/$mac/" /home/ec2-user/kvm/ifcfg-fedora/192.168.122.$i/ifcfg-ens4
done
