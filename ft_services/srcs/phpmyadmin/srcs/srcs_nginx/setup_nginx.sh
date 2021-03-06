#!/bin/sh

mkdir -p /run/nginx

ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log
ln -sf /dev/stderr /var/log/php7/error.log
