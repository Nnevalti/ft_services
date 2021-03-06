#!/bin/sh

if [ ! -d "/run/mysqld" ]; then
	mkdir -p /run/mysqld
	chown -R mysql:mysql /run/mysqld
fi

echo 'Initializing data directory and system necessary tables at standard place'
mysql_install_db --user=mysql --datadir=/var/lib/mysql/  #> /dev/null

tail -f /var/lib/mysql/mysql_log_.err &
tail -f /var/lib/mysql/mysql_log_.log &

nohup init_my_db.sh &

/usr/bin/mysqld_safe --datadir="/var/lib/mysql/"
