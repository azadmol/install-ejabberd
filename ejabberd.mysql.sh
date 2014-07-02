#!/bin/bash

if [ ${#@} != 1 ]; then
	echo "Usage:ejabberd.mysql.sh username"
	exit
fi

mysql -u $1 -p < ./ejabberd.mysql.sql
