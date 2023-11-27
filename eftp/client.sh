#!/bin/bash

IP=`ip address | grep inet | grep -i enp0s3 | cut -d " " -f 6 | cut -d "/" -f 1`

echo $IP

SERVER="LOCALHOST"

echo "CLIENTE DE EFTP"

echo "(1) Send"

echo "EFTP 1.0" | nc $SERVER 3333

echo "(2) Listen"

DATA=`nc -l -p 3333 -w 0`

echo $DATA

echo "(5) Test & Send" #ENVIA-HANDSHAKE

if [ "$DATA" != "OK_HEADER" ] #paso 5
then
	echo "ERROR 1: BAD HEADER"
	exit 1
fi

echo "BOOM"
sleep 1
echo "BOOM" | nc $SERVER 3333

echo "(6) Listen"

DATA=`nc -l -p 3333 -w 0`
echo $DATA

echo "9 Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then 
	echo "ERROR 2: BAD HANDSHAKE"
	exit 2
fi 

echo "10 Send"

sleep 1

echo "FILE_NAME fary1.txt" | nc $SERVER 3333

echo "11 Listen"

DATA=`nc -l -p 3333 -w 0`

echo "14 Test and Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREFIX"
	exit 3
fi 
sleep 1
cat imgs/fary1.txt | nc $SERVER 3333

echo "15 Listen"
DATA=`nc -l -p 3333 -w 0`

if [ "$DATA" != "OK_DATA" ]
then 
	echo "ERROR 4: BAD DATA"
	exit 4
fi 
echo "FIN"
exit 0
