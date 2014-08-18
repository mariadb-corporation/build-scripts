!/bin/bash

# $1 - image name
# $2 - last digits of IP

image_name="$1"
IP_end="$2"
N="$3"

ssh -i /home/ec2-user/KEYS/$image_name -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.$IP_end 'service iptables stop'

/home/ec2-user/test-scripts/c/connect100 192.168.122.$IP_end &
sleep 10
ps ax | grep mysql

Master_IP=`expr $IP_end + 1`
New_Master_IP=`expr $IP_end + 2`

/home/ec2-user/test-scripts/processlist_slave.sh $Master_IP
#a1=$?

#/home/ec2-user/test-setup-scripts/change_master.sh $image_name $IP_end $N $Master_IP $New_Master_IP 

#sleep 10
#/home/ec2-user/test-scripts/c/connect 192.168.122.$IP_end &
#sleep 10

#/home/ec2-user/test-scripts/processlist.sh $New_Master_IP
#a2=$?

#if [[ $a1==0 && $a2==0 ]] ; then
#   exit 0
#else
#   exit 1
#fi
