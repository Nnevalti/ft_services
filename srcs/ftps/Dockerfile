FROM alpine:latest
MAINTAINER Vdescham <vdescham@student.42.fr>

# Install FTPS and dependencies
RUN apk update \
&& apk add vsftpd && apk add openssl curl

ADD ./vsftpd.conf			/etc/vsftpd/vsftpd.conf
ADD ./setup.sh				/srcs/setup.sh
ADD ./liveness.sh			/srcs/liveness.sh

# CONFIG OPENSSL
RUN openssl req -x509 -nodes -subj '/C=FR/ST=PARIS/L=PARIS/O=vdescham/CN=localhost' \
		-days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key \
		 -out /etc/ssl/certs/vsftpd.crt

EXPOSE 20 21 21000-21010

CMD ["sh", "/srcs/setup.sh"]
