#!/bin/bash

set -x 

service iptables stop
yum -y install perl-DBD-mysql cpan bzr perl-YAML wget 

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -Uvh epel-release-6*.rpm

yum -y install perl-Time-* perl-Test-* perl-Digest-* perl-Log-* perl-XML-* perl-DBIx-* perl-Statistics-*


perl -MCPAN -e 'install Test::More Digest::MD5 Log::Log4perl XML::Writer DBIx::MyParsePP Statistics::Descriptive Test::Unit'

#perl -MCPAN -e 'install Test::More'
#perl -MCPAN -e 'install Digest::MD5'
#perl -MCPAN -e 'install Log::Log4perl'
#perl -MCPAN -e 'install XML::Writer'
#perl -MCPAN -e 'install DBIx::MyParsePP'
#perl -MCPAN -e 'install Statistics::Descriptive'
#perl -MCPAN -e 'install JSON'
#perl -MCPAN -e 'install Test::Unit'

bzr branch lp:randgen
cd randgen

perl gentest.pl \
   --dsn=dbi:mysql:host=192.168.122.105:port=4008:user=skysql:password=skysql:database=test \
   --gendata=conf/examples/example.zz \
   --grammar=conf/examples/example.yy
