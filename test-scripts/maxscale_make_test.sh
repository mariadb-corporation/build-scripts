distro=$1
IP=$2

ssh -i ~/KEYS/$distro -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP 'yum install -y gcc gcc-c++ ncurses-devel bison glibc-devel cmake libgcc perl make libtool openssl-devel libaio MariaDB-devel MariaDB-server; ln -s /lib64/libaio.so.1 /lib64/libaio.so'
ssh -i ~/KEYS/$distro -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP 'cd /home/ec2-user/ ; make ROOT_PATH=`pwd` HOME="" clean; make ROOT_PATH=`pwd` HOME="" depend; make ROOT_PATH=`pwd` HOME="" '

ssh -i ~/KEYS/$distro -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$IP 'cd /home/ec2-user/ ;  ln -s /usr/lib64 /usr/lib64/dynlib; make  ROOT_PATH=`pwd` HOME="" ERRMSG="/usr/share/mysql/english" testall'
