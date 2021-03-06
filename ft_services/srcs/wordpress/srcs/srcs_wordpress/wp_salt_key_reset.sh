#!/bin/sh

if [ ! -f ./wp-config.php ]
then
	echo "ERROR: need to run this script in wp-config.php's directory."
	exit 1
fi

wget https://api.wordpress.org/secret-key/1.1/salt/ -O wp_salt_keys.txt
if [ $? -gt 0 ]
then
	echo " wget failed: salt keys could not be set/changed."
	exit 1
fi

while read -r SALT
do
	SEARCH="$(echo "$SALT" | cut -d "'" -f 2)"
	SEARCH=\'$SEARCH\'
	REPLACE=$(echo "$SALT" | cut -d "'" -f 4)
	ESCAPED_REPLACE=`echo "$REPLACE" | sed 's:[]\[\&\^\$\.\*\/]:\\\&:g'`
	NEWLINE="define( $SEARCH, '$ESCAPED_REPLACE' );"
	sed -i  "s/^define(.*$SEARCH.*/$NEWLINE/" ./wp-config.php
done < wp_salt_keys.txt

echo "wp-salt_keys_reset.sh: salt keys changed in wp-config.php!"

rm wp_salt_keys.txt
