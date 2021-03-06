#!/bin/sh

# creat a ssl key pair for our ftps server.
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -subj '/C=FR/ST=osef/O=osef/CN=osef' -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt &>/dev/null

envsubst '$__CLUSTER_IP__' < /tmp/vsftpd.conf > /etc/vsftpd/vsftpd.conf

adduser -D $__FTP_USER__ && echo "$__FTP_USER__:$__FTP_PASSWORD__" | chpasswd &>/dev/null
echo "$__FTP_USER__" >/etc/vsftpd/chroot.list

touch /var/log/vsftpd.log
tail -f /var/log/vsftpd.log &

usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
