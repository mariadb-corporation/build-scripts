echo "nameserver 8.8.8.8" > /etc/resolv.conf 
apt-get update
#apt-get remove -y --force-yes locales language-pack-en-base language-pack-en ubuntu-minimal
apt-get install -y --force-yes wget

apt-get install -y --force-yes gcc g++ make
wget http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz
tar xzvf cmake-2.8.12.2.tar.gz
cd cmake-2.8.12.2
./bootstrap
make
make install

