FROM alpine:latest

RUN apk update \
	&& apk add nginx openssl openssh-server gettext --no-cache \
	&& mkdir -p /run/nginx \
	&& mkdir -p /var/www/my_server

ENV __SSH_USER__=user
ENV	__SSH_PASSWORD__=password
ENV __PHPMYADMIN_IP__=172.24.0.4
ENV __WORDPRESS_IP__=172.24.0.3
ENV __WORDPRESS_PORT__=5050
ENV __PHPMYADMIN_PORT__=5000


# NGINX
COPY ./srcs/srcs_nginx/setup_nginx.sh /usr/sbin
COPY ./srcs/srcs_nginx/server_config  /tmp/
COPY ./srcs/srcs_nginx/index.html /var/www/my_server/index.html
COPY ./srcs/srcs_nginx/self-signed.conf /etc/nginx/snippets/

# SSH
COPY ./srcs/srcs_ssh/setup_ssh.sh /usr/sbin
COPY ./srcs/srcs_ssh/authorized_keys /root/.ssh/authorized_keys
COPY ./srcs/srcs_ssh/authorized_keys /tmp
#only the ssh public key athentication is available.
COPY ./srcs/srcs_ssh/sshd_config /etc/ssh/sshd_config

COPY ./srcs/init.sh /usr/sbin/

EXPOSE 80 443 22

ENTRYPOINT ["init.sh"]
