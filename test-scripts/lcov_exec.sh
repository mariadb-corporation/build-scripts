set -x

maxdir="/usr/local/skysql/maxscale/"
cd $maxdir
yum install -y wget 
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
wget http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
rpm -Uvh remi-release-6*.rpm epel-release-6*.rpm
yum install -y lcov


lcov --directory $maxdir -c -o maxscale.info.all

lcov -r maxscale.info.all $maxdir/log_manager/test/* -o maxscale.info.1
lcov -r maxscale.info.1 $maxdir/server/core/test/* -o maxscale.info.2

lcov -r maxscale.info.2 /usr/include/mysql/psi/* -o maxscale.info.3
lcov -r maxscale.info.3 /usr/include/mysql/private/* -o maxscale.info

rm -rf ../test_coverage
genhtml -o $maxdir/test_coverage -t "maxscale test coverage" --num-spaces 4 maxscale.info
