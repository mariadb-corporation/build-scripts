#/bin/bash

# $1 - end of IP of the node to which maxscale should be connected

set -x

conn_node="$1"

#echo "106:"
#echo "show processlist;" | mysql -h 192.168.122.106 -uskysql -pskysql | grep "105"
#echo "107:"
#echo "show processlist;" | mysql -h 192.168.122.107 -uskysql -pskysql | grep "105"
#echo "108:"
#echo "show processlist;" | mysql -h 192.168.122.108 -uskysql -pskysql | grep "105"
#echo "109:"
#echo "show processlist;" | mysql -h 192.168.122.109 -uskysql -pskysql | grep "105"

a=0

for i in $(seq 106 109)
do
	lines=`echo "show processlist;" | mysql -h 192.168.122.$i -uskysql -pskysql | grep "105" | grep "test" | wc -l`
	echo "Number of connections to $i is $lines"
#	if [ "$i" == "$conn_node" ] ; then 
#		if [ $lines != 0 ] ; then
#			a=1
#		fi
#	else
#		if [[ $lines > 34 || $lines < 32 ]] ; then
#			a=1
#		fi
#	fi
done

#exit $a
