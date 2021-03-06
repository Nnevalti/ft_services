#!/bin/sh

setup_nginx.sh

setup_ssh.sh

nginx
if [ $? -ne 0 ]; then
  echo "Failed to start nginx: $?"
  exit $?
fi

/usr/sbin/sshd -e
if [ $? -ne 0 ]; then
  echo "Failed to start sshd: $?"
  exit $?
fi

while sleep 20; do
  ps aux | grep nginx | grep -q -v grep
  if [ $? -ne 0 ];
	then
		echo "nginx already exited: $?"
		exit $?
	fi
  ps aux | grep sshd | grep -q -v grep
  if [ $? -ne 0 ];
  then
    echo "sshd already exited: $?"
    exit $?
  fi
done
