FROM alpine:latest
MAINTAINER Vdescham <vdescham@student.42.fr>

RUN apk update \
	&& apk add nginx \
	&& mkdir -p /run/nginx \
	&& mkdir -p /var/www/my_server \
	&& apk add openssl openssh-server gettext \
	&& rm -rf /var/cache/apk/*

ENV SSH_USER=user
ENV	SSH_PASSWORD=password
ENV WP_IP=172.24.0.3
ENV WP_PORT=5050
ENV PHPMA_IP=172.24.0.4
ENV PHPMA_PORT=5000

EXPOSE 22 80 443

# NGINX
COPY ./srcs/srcs_nginx/nginx_setup.sh /usr/sbin
COPY ./srcs/srcs_nginx/nginx.conf  /tmp/
COPY ./srcs/srcs_nginx/index.html /var/www/my_server/index.html
COPY ./srcs/srcs_nginx/self-signed.conf /etc/nginx/snippets/

# SSH
COPY ./srcs/srcs_ssh/ssh_setup.sh /usr/sbin
COPY ./srcs/srcs_ssh/authorized_key /root/.ssh/authorized_keys
COPY ./srcs/srcs_ssh/authorized_key /tmp
COPY ./srcs/srcs_ssh/ssh_banner /tmp/ssh_banner
COPY ./srcs/srcs_ssh/sshd_config /etc/ssh/sshd_config

COPY ./srcs/setup.sh /usr/sbin/

ENTRYPOINT ["setup.sh"]
