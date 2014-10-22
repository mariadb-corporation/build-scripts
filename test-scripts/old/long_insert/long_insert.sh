# $1 - IP

IP=$1

mysql -h $IP -P 4006 -u maxuser -pmaxpwd < /home/ec2-user/test-scripts/long_insert/test_init.sql

echo "RWSplit router:"
for ((i=0 ; i<1000 ; i++)) ; do 
	echo "iteration: $i"
	mysql -h $IP -P 4006 -u maxuser -pmaxpwd < /home/ec2-user/test-scripts/long_insert/test_query.sql 
done

echo "ReadConn router (master):"
for ((i=0 ; i<1000 ; i++)) ; do 
        echo "iteration: $i"
        mysql -h $IP -P 4008 -u maxuser -pmaxpwd < /home/ec2-user/test-scripts/long_insert/test_query.sql 
done

