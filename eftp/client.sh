#!/bin/bash

IP= `ip address | grep inet | grep -i enp0s3 | cut -d " " - f 6 | cut -d "/" -f 1`

echo $IP

SERVER= “LOCALHOST”

echo "CLIENTE DE EFTP"

echo "(1) Send"

echo "EFTP 1.0" | nc LOCALHOST 3333

echo "(2) Listen"

DATA=`nc -l -p 3333 -w 0`

echo $DATA

echo "(5) Test & Send"

if [ "$DATA" != "OK_HEADER" ] #paso 5
then
	echo "ERROR 1: BAD HEADER"
	exit 1
fi

echo "BOOM"
sleep 1
echo "BOOM" | nc LOCALHOST 3333

echo "(6) Listen"

DATA=`nc -l -p 3333 -w 0`
echo $DATA
