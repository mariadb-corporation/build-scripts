echo "SHOW GLOBAL STATUS LIKE 'COM_SELECT';" | mysql -pskysql -uskysql -h 192.168.122.106 | grep -i "Com"
echo "SHOW GLOBAL STATUS LIKE 'COM_SELECT';" | mysql -pskysql -uskysql -h 192.168.122.107 | grep -i "Com"
echo "SHOW GLOBAL STATUS LIKE 'COM_SELECT';" | mysql -pskysql -uskysql -h 192.168.122.108 | grep -i "Com"
echo "SHOW GLOBAL STATUS LIKE 'COM_SELECT';" | mysql -pskysql -uskysql -h 192.168.122.109 | grep -i "Com"

#echo "SHOW GLOBAL STATUS LIKE 'COM_INSERT';" | mysql -pskysql -uskysql -h 192.168.122.106 | grep -i "Com"
#echo "SHOW GLOBAL STATUS LIKE 'COM_INSERT';" | mysql -pskysql -uskysql -h 192.168.122.107 | grep -i "Com"
#echo "SHOW GLOBAL STATUS LIKE 'COM_INSERT';" | mysql -pskysql -uskysql -h 192.168.122.108 | grep -i "Com"
#echo "SHOW GLOBAL STATUS LIKE 'COM_INSERT';" | mysql -pskysql -uskysql -h 192.168.122.109 | grep -i "Com"


#echo "SELECT * FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME='COM_INSERT'\G" | mysql -pskysql -uskysql -h 192.168.122.106 | grep "VALUE"
#echo "SELECT * FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME='COM_INSERT'\G" | mysql -pskysql -uskysql -h 192.168.122.107 | grep "VALUE"
#echo "SELECT * FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME='COM_INSERT'\G" | mysql -pskysql -uskysql -h 192.168.122.108 | grep "VALUE"
#echo "SELECT * FROM INFORMATION_SCHEMA.GLOBAL_STATUS WHERE VARIABLE_NAME='COM_INSERT'\G" | mysql -pskysql -uskysql -h 192.168.122.109 | grep "VALUE"
