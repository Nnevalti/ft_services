#!/bin/sh

cd /usr/share/webapps/wordpress
wp core is-installed > /dev/null 2>&1
if [[ $? = 0 ]]
then
	echo "wp-cli: Wordpress already have a database :\n name: $__DB_NAME__ / address: $__DB_HOST__"
	exit 0
fi

echo "wp-cli: wordpress not installed yet at address: $__DB_HOST__ with database: $__DB_NAME__ "

LIMIT=11
while :
do
	echo "Waiting for database to connect"
	wp core is-installed 2>&1 | grep "Error establishing" > /dev/null
	if [[ $? = 0 ]]
	then
		let "LIMIT--"
		echo "$LIMIT"
		sleep 1
		if [[ $LIMIT = 0 ]]
		then
			exit 1
		fi
	else
		echo "OK!"
		break
	fi
done

wp core install --url=http://${__WORDPRESS_SVC_IP__}:${__WORDPRESS_SVC_PORT__} --title="Ft_services" --admin_user=user --admin_password=password --admin_email=user@42.fr --skip-email
wp term create category osef
wp post create /tmp/content_first_post.txt --post_author=1 --post_category="osef" --post_title="first post" --post_excerpt="project 42" --post_status=publish | awk '{gsub(/[.]/, ""); print $4}' > /tmp/postid
wp user create editor editor@example.com --role=editor --user_pass=editor
wp user create author author@example.com --role=author --user_pass=author
wp user create contributor contributor@example.com --role=contributor --user_pass=contributor
wp user create subscriber subscriber@example.com --role=subscriber --user_pass=subscriber
wp theme activate twentyseventeen
wp option update blogdescription "Ft_services wordpress"
