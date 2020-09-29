FROM alpine:latest
MAINTAINER Vdescham <vdescham@student.42.fr>

# Install Wordpress and dependencies
RUN apk update \
&& apk add php7 php7-fpm php7-opcache \
php7-gd php7-mysqli php7-zlib php7-curl \
php7-mbstring php7-json php7-session

RUN wget https://wordpress.org/latest.tar.gz \
&& tar -xzvf latest.tar.gz \
&& rm latest.tar.gz &&\
		mv wordpress /var/www/html/wordpress && \
		chown -R www-data:www-data /var/www/html/wordpress/ &&\
		chmod -R 755 /var/www/html/wordpress/ && \
		rm var/www/html/index.nginx-debian.html && rm /var/www/html/wordpress/wp-config-sample.php

	//	&& mkdir /www \
	//	&& mv wordpress/ www/

ADD ./setup.sh 			/srcs/setup.sh
ADD ./liveness.sh		/srcs/liveness.sh

EXPOSE 5050

CMD ["sh", "/srcs/setup.sh"]
