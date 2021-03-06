#!/bin/sh

ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/C=FR/O=osef/OU=osef/CN=osef" 2>&1 >/dev/null

envsubst '$__WORDPRESS_IP__ $__PHPMYADMIN_IP__ $__WORDPRESS_PORT__ $__PHPMYADMIN_PORT__ '  < /tmp/server_config > /etc/nginx/conf.d/default.conf
rm /tmp/server_config
