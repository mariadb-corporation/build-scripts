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
# Date: July 2013
# Author: Massimo Siani
# Date: May 2014: fixes for Debian/Ubuntu, user creation checks.
#
# This script does the necessary configuration steps to have the node ready for
# command execution.
#

# $1 - IP
# $2 - node name

set -x

. /root/detect_distro.sh

privateip=$1
nodename=$2
rep_username="repl"
rep_password="repl"
db_username="skysql"
db_password="skysql"

# Determining path of galera library
if [[ -f /usr/lib/galera/libgalera_smm.so ]]; then
	galera_lib_path="/usr/lib/galera/libgalera_smm.so"
elif [[ -f /usr/lib64/galera/libgalera_smm.so ]]; then
	galera_lib_path="/usr/lib64/galera/libgalera_smm.so"
else
	echo "Failed to find Galera wsrep library."
	exit 1
fi

# Creating MariaDB configuration file
hostname=$(uname -n)
if [[ "$linux_name" == "CentOS" || "$linux_name" == "Fedora" ]]; then
        sed -e "s/###NODE-ADDRESS###/$privateip/g" \
                -e "s/###NODE-NAME###/$nodename/g" \
                -e "s/###REP-USERNAME###/$rep_username/g" \
                -e "s/###REP-PASSWORD###/$rep_password/g" \
                -e "s|###GALERA-LIB-PATH###|$galera_lib_path|g" \
                /root/conf_files/skysql-galera.cnf > /etc/my.cnf.d/skysql-galera.cnf

	if [[ ! -s /etc/my.cnf.d/skysql-galera.cnf ]]; then
	        echo "Error generating galera configuration file"
        	exit 1
	fi
	if [[ "$xtrabackup" == "yes" ]]; then
		sed -i "s/wsrep_sst_method=rsync/wsrep_sst_method=xtrabackup-v2/" /etc/my.cnf.d/skysql-galera.cnf
	#	yum install -y percona-xtrabackup-20
	fi
	yum install -y percona-xtrabackup-20
elif [[ "$linux_name" == "Debian" || "$linux_name" == "Ubuntu" ]]; then
        echo "!includedir /etc/mysql/conf.d/" > /etc/mysql/my.cnf
        sed -e "s/###NODE-ADDRESS###/$privateip/g" \
                -e "s/###NODE-NAME###/$nodename/g" \
                -e "s/###REP-USERNAME###/$rep_username/g" \
                -e "s/###REP-PASSWORD###/$rep_password/g" \
                -e "s|###GALERA-LIB-PATH###|$galera_lib_path|g" \
                /root/conf_files/skysql-galera.cnf > /etc/mysql/conf.d/skysql-galera.cnf

	if [[ ! -s /etc/mysql/conf.d/skysql-galera.cnf ]]; then
        	echo "Error generating galera configuration file"
	        exit 1
	fi
        if [[ "$xtrabackup" == "yes" ]]; then
                sed -i "s/wsrep_sst_method=rsync/wsrep_sst_method=xtrabackup-v2/" /etc/my.cnf.d/skysql-galera.cnf
                apt-get install -y --force-yes percona-xtrabackup-20
        fi
	#apt-get install -y --force-yes percona-xtrabackup-20
fi

# Setting up MariaDB users
/etc/init.d/mysql start --wsrep-cluster-address=gcomm://

sleep 5

mysql -u root -e "DELETE FROM mysql.user WHERE user = ''; \
GRANT ALL PRIVILEGES ON *.* TO $rep_username@'%' IDENTIFIED BY '$rep_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO $db_username@'%' IDENTIFIED BY '$db_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO $rep_username@'localhost' IDENTIFIED BY '$rep_password'  WITH GRANT OPTION; \
GRANT ALL PRIVILEGES ON *.* TO $db_username@'localhost' IDENTIFIED BY '$db_password'  WITH GRANT OPTION; \
FLUSH PRIVILEGES;"

# Check users before stopping the server
mysql -u root -e "SELECT user FROM mysql.user WHERE user = '$rep_username'" | grep -q "$rep_username"
if [[ "$?" != 0 ]] ; then
	echo "Replication user not created"
	exit 1
fi
mysql -u root -e "SELECT user FROM mysql.user WHERE user = '$rep_username'" | grep -q "$rep_username"
if [[ "$?" != 0 ]] ; then
	echo "Database user not created"
	exit 1
fi

/etc/init.d/mysql stop

if [[ "$linux_name" == "CentOS" || "$linux_name" == "Fedora" ]]; then
        my_cnf_path="/etc/my.cnf"
elif [[ "$linux_name" == "Debian" || "$linux_name" == "Ubuntu" ]]; then
        my_cnf_path="/etc/mysql/my.cnf"
fi

if [[ my_cnf_path = "" ]]; then
	echo "Error detecting my.cnf file"
	exit 1
fi

cat $my_cnf_path | grep -q ^datadir=.*
if [[ $? = 0 ]]; then
        sed -e "s|datadir=.*|datadir=/var/lib/mysql|" $my_cnf_path > /tmp/my.cnf.tmp
        mv /tmp/my.cnf.tmp $my_cnf_path
else
        echo "[mysqld]" >> $my_cnf_path
        echo "datadir=/var/lib/mysql" >> $my_cnf_path
fi

# Disabling mysqld auto startup on boot
if [[ "$linux_name" == "CentOS" || "$linux_name" == "Fedora" ]]; then
	chkconfig --del mysql
elif [[ "$linux_name" == "Debian" || "$linux_name" == "Ubuntu" ]]; then
	update-rc.d -f mysql remove
fi

