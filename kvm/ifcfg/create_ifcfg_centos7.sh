#/bin/bash
for i in $(seq 100 199)
do
	mkdir -p /home/ec2-user/kvm/ifcfg-centos7/192.168.122.$i
	cp /home/ec2-user/kvm/ifcfg-centos7/ifcfg-ens3 /home/ec2-user/kvm/ifcfg-centos7/192.168.122.$i/
	cp /home/ec2-user/kvm/ifcfg-centos7/ifcfg-ens4 /home/ec2-user/kvm/ifcfg-centos7/192.168.122.$i/
	IP=`echo $i`
#	echo $IP
	sed -i "s/###IP###/$IP/" /home/ec2-user/kvm/ifcfg-centos7/192.168.122.$i/ifcfg-ens4
	mac_dec=`expr $i - 100`
	mac=`printf '%x' $mac_dec`
#	echo $mac
	if [ $mac_dec -lt 16 ] ; then
		mac=`echo 0$mac`
	fi
	sed -i "s/###mac###/$mac/" /home/ec2-user/kvm/ifcfg-centos7/192.168.122.$i/ifcfg-ens4
done
