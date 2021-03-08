#!/bin/sh

SERVICE_LIST="ftps nginx wordpress phpmyadmin mysql grafana influxdb"

check_input()
{
	if [ $# -lt 1 ]
	then
		echo "\nusage: give as argument the ip address of the cluster"
		exit
	fi
}

ckeck_list_and_names()
{
	echo "\n1) Checking that all the services exist and have the correct name:"
	for SERVICE in $SERVICE_LIST
	do
		kubectl get pods | grep $SERVICE- 2>&1 > /dev/null
		if [ $? -ne 0 ]
		then
			echo "${RED}ERROR: service  $SERVICE is missing or was not named correctly${SET}"	
			exit
		else
			echo "${GREEN} $SERVICE  ✅ ${SET}"
		fi
	done

	echo "\n2) Checking that all the pods are Running"
	for SERVICE in $SERVICE_LIST
	do
		RUNNING=`kubectl get pods | grep $SERVICE | tr -s ' ' | cut -d ' ' -f 3`
		if [ "$RUNNING" = "Running" ]
		then
			echo "${GREEN} $SERVICE is Running  ✅ ${SET}"
		else
			echo "${RED}ERROR: $SERVICE is not Running ${SET}"
			exit
		fi
	done
}

check_no_restarts_yet()
{
	echo "\n3) Checking that all the services have not been restarted yet:"

	for SERVICE in $SERVICE_LIST
	do
		RESTARTS=`kubectl get pods | grep $SERVICE | tr -s ' ' | cut -d ' ' -f 4`
		if [ $RESTARTS -eq 0 ]
		then
			echo "${GREEN} $SERVICE: 0 RESTARTS ✅ ${SET}"
		else
			echo "${RED} ERROR: $SERVICE restarted $RESTARTS time(s) ${SET}"
			#exit
		fi
	done
}

kill_all_processes()
{
	echo "\n4) ☠️ Killing all the processes: ☠️"
	echo "note: pure-ftpd and vsftpd are tried both, so there might be an error message...\n"
	for SERVICE in $SERVICE_LIST
	do
		POD_NAME=`kubectl get pods | grep $SERVICE | cut -d ' ' -f 1`
		case $SERVICE in
			nginx | telegraf)
			kubectl exec $POD_NAME -- pkill $SERVICE 2>&1 > /dev/null
			;;
			ftps)
			kubectl exec $POD_NAME -- pkill vsftpd 2>&1 > /dev/null
			kubectl exec $POD_NAME -- pkill pure-ftpd 2>&1 > /dev/null
			;;
			mysql)
			kubectl exec $POD_NAME -- pkill mysqld 2>&1 > /dev/null
			;;
			influxdb)
			kubectl exec $POD_NAME -- pkill influxd 2>&1 > /dev/null
			;;
			grafana)
			kubectl exec $POD_NAME -- pkill grafana-server 2>&1 > /dev/null
			;;
			wordpress)
			kubectl exec $POD_NAME -- pkill nginx 2>&1 > /dev/null
			;;
			phpmyadmin)
			kubectl exec $POD_NAME -- pkill php 2>&1 > /dev/null
			;;
			*)
			;;
		esac
	done
}

ask_to_open_new_terminal()
{ 
	echo "\n5) Wait and check in another terminal windowsXP if there is any containers/pods that cannot restart:"
	echo -n "\nuse the command:"
	echo "${GREEN} kubectl get pods --watch ${SET}"
	echo "\ngive them a good minute or two: be fair..."

	echo -n "\nPress 'ENTER' when you are ready to keep on."
	read REPLY 
}

display_for_correction()
{
	clear;
	echo "NOW its time to really check if the services are working correctly..."

	IP="\033[38;5;187m$1${SET}"
	echo "\ngenerating links for the given cluster IP: $IP"
	echo "\n\n \033[4m\033[38;5;255m CORRECTION LINKS: ${SET}\n"
	echo " - wordpress:                     http://$IP:5050"
	echo " - phpmyadmin:                     http://$IP:5000"
	echo " - grafana:                        http://$IP:3000"
	echo " - nginx:"
	echo "    - with redirect to https:      http://$IP or $IP"
	echo "    - https:                       https://$IP" 
	echo "    - reverse proxy to phpma:      https://$IP:443/phpmyadmin"
	echo "    - temporary redirect to wp:    https://$IP:443/wordpress\n"
}
check_input $1
ckeck_list_and_names;
check_no_restarts_yet;
kill_all_processes;
ask_to_open_new_terminal;
display_for_correction $1;
