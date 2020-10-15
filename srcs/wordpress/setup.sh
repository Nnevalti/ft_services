set -x

# PHP SERVER
openrc
touch /run/openrc/softlevel
rc-service nginx start
rc-service php-fpm start

# SSH starting
echo -e "$PASSWORD\n$PASSWORD" | adduser $USER
rc-update add sshd
rc-status
/etc/init.d/sshd start

tail -f /dev/null # Freeze command to avoid end of container
