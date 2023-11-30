#!/bin/bash
CLIENT="localhost"
PORT=3333

echo “Servidor de EFTP”

TIMEOUT=1

echo "(0) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`

PREFIX=`echo $DATA | cut -d " " -f 1`
VERSION=`echo $DATA | cut -d " " -f 2`


echo "(3)  Test and Send" #comprobar si lo que ha llegado es igual a la cabecera de “eftp 1.0”

if [ "$PREFIX $VERSION" != "EFTP 1.0" ]

then 

	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1

fi

CLIENT=`echo $DATA | cut -d " " -f 3`

if [ "$CLIENT" == "" ]
then 
	echo "ERROR: NO IP"
	exit 1
fi

echo "OK_HEADER"

sleep 1

echo "OK_HEADER" | nc $CLIENT $PORT

echo "(4)  Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT` #paso 4 escuchar
echo $DATA

echo "(7)  Test and Send"

if [ "$DATA" != "BOOOM" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT $PORT
	exit 1

fi

sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT $PORT

echo "(8)a listen numero de archivos"
echo "(8)b Send OK/KO"
echo "8  Listen"


DATA=`nc -l -p $PORT -w $TIMEOUT`
echo $DATA

echo "(12) TestStored&Send"

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX"  != "FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREXIX"
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi
FILE_NAME=`echo $DATA | cut -d " " -f 2`
FILE_MD5=`echo $DATA | cut -d " " -f 3`
FILE_MD5_LOCAL=`echo $FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then 
	echo "ERROR 3: BAD FILE NAME MD5"
	sleep 1
	echo "KO_FILE_NAME" | nc $CLIENT $PORT
	exit 3
fi

echo "OK_FILE_NAME" | nc $CLIENT $PORT

echo "(13) listen"
nc -l -p $PORT -w $TIMEOUT > inbox/$FILE_NAME

DATA=`cat inbox/$FILE_NAME`

echo "(16) Store and send"
if [ "$DATA" == "" ]
then 
	echo "ERROR 4: EMPTY DATA"
	sleep 1
	echo "KO_DATA" | nc $CLIENT $PORT
	exit 4
fi 


sleep 1
echo "OK_DATA" | nc $CLIENT $PORT

echo "(17) Listen"

DATA=`nc -l -p $PORT -w $TIMEOUT`
sleep 1
echo "(20) Test and Send"

echo $DATA

PREFIX=`echo $DATA | cut -d " " -f 1`

if [ "$PREFIX" != "FILE_MD5" ]
then 
	echo "ERROR 5: BAD FILE MD5 PREFIX"
	echo "KO_FILE_MD5" | nc $CLIENT $PORT
	exit 5
fi

FILE_MD5=`echo $DATA | cut -d " " -f 2`
FILE_MD5_LOCAL=`cat inbox/$FILE_NAME | md5sum | cut -d " " -f 1`

if [ "$FILE_MD5" != "$FILE_MD5_LOCAL" ]
then 
	echo "ERROR 5: BAD FILE MD5"
	echo "KO_FILE_MD5" | nc $CLIENT $PORT
	exit 5
fi 

echo "FIN"
exit 0
