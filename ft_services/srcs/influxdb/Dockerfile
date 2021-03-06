### check associated README.txt for explanations and details.
FROM alpine:latest

RUN apk update \
	&& apk add influxdb \
	&& rm -rf /var/cache/apk/*

COPY srcs/init.sh /usr/sbin

EXPOSE 8086

ENTRYPOINT ["init.sh"]
