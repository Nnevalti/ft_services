FROM alpine:latest

RUN apk update && apk add openssl vsftpd gettext --no-cache

ENV __FTPS_USER__=user
ENV __FTPS_PASSWORD__=password
ENV __CLUSTER_IP__=172.17.0.2

COPY ./srcs/vsftpd.conf /tmp/vsftpd.conf
COPY ./srcs/init.sh /usr/sbin

EXPOSE 21

ENTRYPOINT ["init.sh"]
