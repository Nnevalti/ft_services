FROM alpine:latest
MAINTAINER Vdescham <vdescham@student.42.fr>

# Install Grafana
RUN apk add openrc

RUN wget https://dl.grafana.com/oss/release/grafana-7.1.5.linux-amd64.tar.gz \
&& tar -zxf grafana-7.1.5.linux-amd64.tar.gz \
&& mv grafana-7.1.5 grafana \
&& rm -r grafana-7.1.5.linux-amd64.tar.gz

# Required by grafana-server dependency to run grafana binary
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

ADD ./setup.sh					/srcs/setup.sh
ADD ./datasource.yaml 			grafana/conf/provisioning/datasources/
ADD ./dashboard.yaml 			grafana/conf/provisioning/dashboards/
ADD ./dashboard_overview.json 	/var/lib/grafana/dashboards/

EXPOSE 3000

CMD ["sh", "/srcs/setup.sh"]
