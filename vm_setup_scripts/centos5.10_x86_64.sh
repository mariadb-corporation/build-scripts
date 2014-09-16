yum install -y wget
wget http://download.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm

yum install -y gcc gcc-c++
wget http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
tar xzvf cmake-2.8.12.2.tar.gz
cd cmake-2.8.12.2
./bootstrap
gmake
make install

