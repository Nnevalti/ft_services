FROM alpine:latest
MAINTAINER Vdescham <vdescham@student.42.fr>

# Install Wordpress and dependencies
RUN apk update \
&& apk add php7 php7-fpm php7-opcache \
php7-gd php7-mysqli php7-zlib php7-curl \
php7-mbstring php7-json php7-session \
wget openrc nginx openssl openssh

RUN wget http://fr.wordpress.org/latest-fr_FR.tar.gz
RUN tar -xzvf latest.tar.gz
RUN rm latest.tar.gz
RUN mkdir www
RUN mv wordpress/ www/

ADD ./nginx.conf		/etc/nginx/nginx.conf
ADD ./sshd_config 		/etc/ssh/
ADD ./wp_config.php		/www/wordpress/wp-config.php
ADD ./setup.sh 			/srcs/setup.sh
ADD ./liveness.sh		/srcs/liveness.sh

RUN openssl req -x509 -nodes -subj '/C=FR/ST=PARIS/L=PARIS/O=vdescham/CN=localhost' \
		 -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl_key.key \
		 -out /etc/ssl/certs/ssl_certificate.crt

EXPOSE 5050

CMD ["sh", "/srcs/setup.sh"]
