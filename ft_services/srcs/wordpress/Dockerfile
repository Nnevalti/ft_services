FROM alpine:latest

ENV __DB_NAME__=wordpress
ENV __DB_USER__=user
ENV __DB_PASSWORD__=password
ENV __DB_HOST__=127.0.0.1
ENV __DB_PORT__=3306
ENV __DB_TABLE_PREFIX__=aha_archi_wp_
ENV	__WORDPRESS_SVC_IP__=localhost
ENV __WORDPRESS_SVC_PORT__=5050

RUN apk update \
	&& apk add nginx \
	&& apk add php7 php7-bcmath php7-ctype php7-curl php7-fpm php7-gd php7-iconv \
       	php7-intl	php7-json php7-mbstring php7-mcrypt php7-mysqlnd php7-opcache \
       	php7-openssl php7-pdo php7-pdo_mysql php7-mysqli php7-pdo_pgsql php7-pdo_sqlite \
       	php7-phar php7-posix php7-session php7-soap php7-xml php7-zip \
	&& wget -P /tmp/ http://wordpress.org/latest.tar.gz \
	&& wget -P /tmp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
	&& chmod +x /tmp/wp-cli.phar && mv /tmp/wp-cli.phar /usr/sbin/wp \
	&& rm -rf /var/cache/apk/*

COPY /srcs/init.sh /usr/sbin

COPY ./srcs/srcs_wordpress/setup_wordpress.sh /usr/sbin
COPY ./srcs/srcs_wordpress/wp_salt_key_reset.sh /usr/sbin/
COPY ./srcs/srcs_wordpress/config_wordpress_site.sh /usr/sbin
COPY ./srcs/srcs_wordpress/first_post.txt /tmp

COPY ./srcs/srcs_nginx/setup_nginx.sh /usr/sbin
COPY ./srcs/srcs_nginx/wp_server.conf /etc/nginx/conf.d

EXPOSE 5050

CMD ["init.sh"]
