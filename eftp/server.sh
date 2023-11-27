#!/bin/bash
CLIENT="LOCALHOST"


echo “Servidor de EFTP”

echo “0  Listen”

DATA=`nc -l -p 3333 -w 0`

echo $DATA

echo "3  Test and Send" #comprobar si lo que ha llegado es igual a la cabecera de “eftp 1.0”

if ["$DATA" != "EFTP 1.0" ]

then 

	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT 3333
	exit 1

fi

echo "OK_HEADER"

sleep 1

echo "OK_HEADER" | nc $CLIENT 3333

echo "4  Listen"

DATA=`nc -l -p 3333 -w 0` #paso 4 escuchar
echo $DATA

echo "7  Test and Send"

if ["$DATA" != "BOOM" ]
then
	echo "ERROR 1: BAD HEADER"
	sleep 1
	echo "KO_HEADER" | nc $CLIENT 3333
	exit 1

fi

echo "OK_HANDSHAKE"
sleep 1
echo "OK_HANDSHAKE" | nc $CLIENT 3333

echo "8  Listen"


DATA=`nc -l -p 3333 -w 0`

echo "12 TestStored&Send"

PREXIS=`echo $DATA | cut -d " " -f 1`

if ["$PREFIX"  != "FILE_NAME" ]
then 
	echo "ERROR 3: BAD FILE NAME PREXIX"
	exit 3
fi
FILE_NAME=`echo $DATA | cut -d " " -f 2`

echo "13 listen"
DATA=`nc -l -p 3333 -w 0`

echo "16 Store and send"
if ["$DATA" == "" ]
then 
	echo "ERROR 4: BAD FILE NAME PREFIX"
	sleep 1
	echo "KO_DATA" | nc $CLIENT 3333
	exit 4
fi 
echo $DATA > inbox/$FILE_NAME

sleep 1
echo "OK_DATA" | nc $CLIENT 3333
echo "FIN"
exit 0
