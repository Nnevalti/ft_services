FROM alpine:latest
MAINTAINER Vdescham <vdescham@student.42.fr>

RUN apk update && apk add openrc nginx openssl openssh

ADD ./nginx.conf		/etc/nginx/nginx.conf
ADD ./setup.sh 			/srcs/setup.sh
RUN chmod +x 			/srcs/setup.sh
RUN mkdir www
ADD ./index.html		/www/index.html
ADD ./liveness.sh		/srcs/liveness.sh

RUN openssl req -x509 -nodes -subj '/C=FR/ST=PARIS/L=PARIS/O=vdescham/CN=localhost' \
		 -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ssl_key.key \
		 -out /etc/ssl/certs/ssl_certificate.crt

ADD ./sshd_config 		/etc/ssh/

EXPOSE 22 80 443

CMD ["sh", "/srcs/setup.sh"]
