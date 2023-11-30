#!/bin/bash

if [ $# -eq 0 ]
then
	SERVER="localhost"
elif [ $# -eq 1 ]
then 
	SERVER=$1
fi	

SERVER="localhost"
IP=`ip address | grep inet | grep -i enp0s3 | cut -d " " -f 6 | cut -d "/" -f 1`

echo $IP

PORT=3333


TIMEOUT=1

echo "CLIENTE DE EFTP"

echo "(1) Send"

echo "EFTP 1.0 $IP" | nc $SERVER $PORT

echo "(2) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA

echo "(5) Test & Send" #ENVIA-HANDSHAKE

if [ "$DATA" != "OK_HEADER" ] #paso 5
then
	echo "ERROR 1: BAD HEADER"
	exit 1
fi

echo "BOOOM"
sleep 1
echo "BOOOM" | nc $SERVER $PORT

echo "(6) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(9) Test"

if [ "$DATA" != "OK_HANDSHAKE" ]
then 
	echo "ERROR 2: BAD HANDSHAKE"
	exit 2
fi 

echo "(10)a leer todos los archivos de imgs"
echo "(10)b Listen (8b)"
echo "(10) Send"

sleep 1

FILE_NAME="fary1.txt"

FILE_MD5=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

echo "FILE_NAME $FILE_NAME $FILE_MD5" | nc $SERVER $PORT



echo "(11) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo $DATA
echo "(14) Test and Send"

if [ "$DATA" != "OK_FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREFIX"
	exit 3
fi 
sleep 1
cat imgs/fary1.txt | nc $SERVER $PORT

echo "(15) Listen"
DATA=`nc -l -p $PORT -w $TIMEOUT`

if [ "$DATA" != "OK_DATA" ]
then 
	echo "ERROR 4: BAD DATA"
	exit 4
fi
sleep 1
echo "(18) Send"

FILE_MD5=`cat imgs/$FILE_NAME | md5sum | cut -d " " -f 1`

 
echo "FILE_MD5 $FILE_MD5" | nc $SERVER $PORT
sleep 1
echo "(19) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

echo "(21) Test"

if [ "$DATA" != "OK_FILE_MD5" ]
then 
	echo "ERROR: FILE MD5"
	exit 5
fi
sleep 1

echo "FIN"
exit 0
