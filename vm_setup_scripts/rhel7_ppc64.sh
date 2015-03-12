yum install -y wget
#wget http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/epel-release-7-1.noarch.rpm
#rpm -ivh epel-release-*.noarch.rpm

yum install -y gcc gcc-c++
wget http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
tar xzvf cmake-2.8.12.2.tar.gz
cd cmake-2.8.12.2
./bootstrap
gmake
make install

