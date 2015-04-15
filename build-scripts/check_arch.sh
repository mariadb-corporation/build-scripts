cat /proc/cpuinfo | grep cpu | grep POWER
if [ $? -ne 0 ] ; then

  dpkg --version
  if [ $? == 0 ] ; then
    export libc6_ver=`dpkg -l | awk '$2=="libc6" { print $3 }'`
    dpkg --compare-versions $libc6_ver lt 2.14
    res=$?
  else
    export libc6_ver=`rpm --query glibc  --qf "%{VERSION}"`
    rpmdev-vercmp $libc6_ver 2.14
    if [ $? == 12 ] ; then
       res=0
    else
       res=1
    fi
  fi

  if [ $res != 0 ] ; then
    export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-5.5.42-linux-glibc_214-x86_64.tar.gz"
    export mariadbd_file="mariadb-5.5.42-linux-glibc_214-x86_64.tar.gz"
  else 
    export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-5.5.42-linux-x86_64.tar.gz"
    export mariadbd_file="mariadb-5.5.42-linux-x86_64.tar.gz"
  fi
else
        export mariadbd_link="http://jenkins.engskysql.com/x/mariadb-5.5.41-linux-ppc64le.tar.gz"
        export mariadbd_file="mariadb-5.5.41-linux-ppc64le.tar.gz"
fi

