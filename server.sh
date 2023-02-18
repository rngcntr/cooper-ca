#!/bin/bash

GREEN="\033[0;32m"
NO_COLOR="\033[0m"

NAME=$1
set -e

echo "Select IntermediateCA for signing"
PS3="Choice: "
select file in $(ls /ca/intermediate/); do
    if [[ -z $file ]]; then
        echo 'Invalid choice, exiting.' >&2
        exit;
    else
        SIGNER=$file
        break
    fi
done

printf "${GREEN}[server]${NO_COLOR} Preparing Directories...\n"
mkdir -p /ca/server/${NAME}/private
mkdir -p /ca/server/${NAME}/certs
mkdir -p /ca/server/${NAME}/csr

printf "${GREEN}[server]${NO_COLOR} Generating Private Key...\n"
openssl genrsa -aes256 -out /ca/server/${NAME}/private/key.pem 2> /dev/null

printf "${GREEN}[server]${NO_COLOR} Generating Certificate Signing Request...\n"
openssl req -config /ca/intermediate/${SIGNER}/openssl.cnf -new -sha256 \
    -key /ca/server/${NAME}/private/key.pem \
    -out /ca/server/${NAME}/csr/csr.pem

printf "${ORANGE}[intermediate]${NO_COLOR} Signing Request From Server...\n"
openssl ca -config /ca/intermediate/${SIGNER}/openssl.cnf -extensions server_cert \
    -days 365 -notext -md sha256 \
    -in /ca/server/${NAME}/csr/csr.pem \
    -out /ca/server/${NAME}/certs/cert.pem

printf "${GREEN}[server]${NO_COLOR} Generating Certificate Chain\n"
cp /ca/intermediate/${SIGNER}/certs/ca-chain.cert.pem /ca/server/${NAME}/certs/ca-chain.cert.pem

printf "${GREEN}[server]${NO_COLOR} Complete!\n"
