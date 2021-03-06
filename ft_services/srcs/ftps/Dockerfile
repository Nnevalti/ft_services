FROM alpine:latest

RUN apk update && apk add openssl \
	&& apk add vsftpd \
	&& apk add gettext \
	&& rm -rf /var/cache/apk/*

ENV __FTP_USER__=user
ENV __FTP_PASSWORD__=password
ENV __CLUSTER_IP__=172.17.0.2

COPY ./srcs/vsftpd.conf /tmp/vsftpd.conf
COPY ./srcs/test.txt /home/user/test.txt
COPY srcs/init.sh /usr/sbin

EXPOSE 21

ENTRYPOINT ["init.sh"]
