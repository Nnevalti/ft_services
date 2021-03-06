#!/bin/sh

chmod 700 /root/.ssh
chmod 600 /root/.ssh/authorized_keys
echo 'root:dummy' | chpasswd &>/dev/null

adduser -D $__SSH_USER__ &>dev/null
echo "$__SSH_USER__:$__SSH_PASSWORD__"|chpasswd &>dev/null

cp /tmp/authorized_keys /home/$__SSH_USER__/.ssh/authorized_keys

chmod 700 /home/$__SSH_USER__/.ssh
chmod 600 /home/$__SSH_USER__/.ssh/authorized_keys

ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
