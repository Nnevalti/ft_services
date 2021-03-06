#!/bin/sh

setup_nginx.sh
setup_phpmyadmin.sh

nginx
if [ $? -ne 0 ];
then
	echo "Failed to start nginx: $?"
	exit $?
fi

php-fpm7
if [ $? -ne 0 ];
then
	echo "Failed to start php-fpm7: $?"
	exit $?
fi

while sleep 20;
do
	ps aux | grep nginx | grep -q -v grep
	if [ $? -ne 0 ];
	then
		echo "nginx already exited: $?"
		exit $?
	fi
	ps aux | grep php-fpm | grep -q -v grep
	if [ $? -ne 0 ];
	then
		echo "php-fpm7 already exited: $?"
		exit $?
	fi
done
