FROM alpine:latest

RUN apk update \
	&& apk add mariadb mariadb-client --no-cache

ENV __MYSQL_DB_NAME__=wordpress
ENV __MYSQL_DB_USER__=user
ENV __MYSQL_DB_PASSWD__=password

ENV __MYSQL_ADMIN__=admin
ENV __MYSQL_ADMIN_PASSWD__=password_admin

COPY srcs/init.sh usr/sbin/init.sh
COPY srcs/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY srcs/init_my_db.sh /usr/sbin/

EXPOSE 3306

ENTRYPOINT ["init.sh"]
