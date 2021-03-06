#!/bin/sh

if [ ! -d "/run/php-fpm7" ]; then
	mkdir -p /run/php-fpm7/
fi
chown -R nginx:www-data /run/php-fpm7/
mkdir -p /usr/share/webapps/phpmyadmin/tmp
tar zxvf /tmp/phpmyadmin.tar.gz --strip-components=1 -C /usr/share/webapps/phpmyadmin/ 2>&1 > /dev/null
chown -R nginx:www-data /usr/share/webapps/
ln -s /usr/share/webapps/phpmyadmin/ /var/www/phpmyadmin

envsubst '$__DB_NAME__ $__DB_USERNAME__ $__DB_PASSWORD__ $__DB_HOST__' < /tmp/config.inc.php > /usr/share/webapps/phpmyadmin/config.inc.php
if [ $? -ne 0 ]
then
	echo "Envsubst command failed"
	exit 1
fi

rm /tmp/phpmyadmin.tar.gz
rm /tmp/config.inc.php
