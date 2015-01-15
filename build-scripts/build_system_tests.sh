zypper -n install rpm-build  gcc gcc-c++ ncurses-devel bison glibc-devel cmake libgcc_s1 perl make libtool libopenssl-devel libaio libaio-devel mariadb libedit-devel 
zypper -n install libmariadbclient-dev mariadb-client

yum install -y rpm-build gcc gcc-c++ ncurses-devel bison glibc-devel libgcc perl make libtool openssl-devel libaio libaio-devel libedit-devel cmake 
yum install -y libmariadbclient-dev MariaDB-devel MariaDB-client
yum install -y libmariadbclient-dev mariadb-devel mariadb-client

apt-get update 
apt-get install -y --force-yes gcc g++ ncurses-dev bison build-essential libssl-dev libaio-dev perl make libtool libmariadbclient-dev cmake mariadb-client

cmake .
make
make install 
