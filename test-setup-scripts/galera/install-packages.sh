#!/bin/bash
#
# This file is distributed as part of MariaDB Manager.  It is free
# software: you can redistribute it and/or modify it under the terms of the
# GNU General Public License as published by the Free Software Foundation,
# version 2.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51
# Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2012-2014 SkySQL Corporation Ab
#
# Author: Marcos Amaral
# Date: October 2013
#
#
# This script installs the necessary MariaDB/Galera packages.
#


set -x

. /root/detect_distro.sh

if [[ "$linux_name" == "CentOS" ]]; then
        # Installing MariaDB packages
        yum -y clean all
	yum install -y wget 
	wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
	rpm -Uvh epel-release-6*.rpm
        yum -y install MariaDB-Galera-server MariaDB-client nc rsync sudo chkconfig sed coreutils util-linux curl grep findutils gawk socat iproute
#yum -y install percona-xtrabackup

        # Checking if packages were correctly installed
        rpm -q MariaDB-Galera-server MariaDB-client
        rpm_q_status=$?

        if [[ "$rpm_q_status" != "0" ]]; then
                echo  "Error installing MariaDB packages."
                exit $rpm_q_status
        fi
elif [[ "$linux_name" == "Debian" || "$linux_name" == "Ubuntu" ]]; then
        # Installing MariaDB packages
        apt-get update
        apt-get install -y --force-yes mariadb-galera-server mariadb-client

        # Checking if packages were correctly installed
        dpkg -s mariadb-galera-server mariadb-client
        dpkg_s_status=$?

        if [[ "$dpkg_s_status" != "0" ]]; then
                echo "Error installing MariaDB packages."
                exit $dpkg_s_status
        fi
fi

exit 0
