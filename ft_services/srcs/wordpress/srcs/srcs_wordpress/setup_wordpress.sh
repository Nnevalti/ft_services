#!/bin/sh

mkdir -p /usr/share/webapps
tar -xzf /tmp/latest.tar.gz  -C /usr/share/webapps/
mkdir -m 777 /usr/share/webapps/wordpress/wp-content/uploads
chown -R nginx:www-data /usr/share/webapps/
rm -rf /tmp/latest.tat.gz
ln -s /usr/share/webapps/wordpress /var/www/wordpress

cd /usr/share/webapps/wordpress
mv  ./wp-config-sample.php wp-config.php

sed -i "s/database_name_here/${__DB_NAME__}/" wp-config.php
sed -i "s/password_here/${__DB_PASSWORD__}/" wp-config.php
sed -i "s/username_here/${__DB_USER__}/" wp-config.php
sed -i "s/localhost/${__DB_HOST__}:${__DB_PORT__}/" wp-config.php
sed -i "s/'wp_'/'$__DB_TABLE_PREFIX__'/" wp-config.php

wp_salt_keys_reset.sh

cd -
