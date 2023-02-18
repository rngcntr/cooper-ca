#!/bin/bash

ORANGE="\033[0;33m"
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

printf "${GREEN}[user]${NO_COLOR} Preparing Directories...\n"
mkdir -p /ca/user/${NAME}/private
mkdir -p /ca/user/${NAME}/certs
mkdir -p /ca/user/${NAME}/csr

printf "${GREEN}[user]${NO_COLOR} Generating Private Key...\n"
openssl genrsa -aes256 -out /ca/user/${NAME}/private/key.pem 2> /dev/null

printf "${GREEN}[user]${NO_COLOR} Generating Certificate Signing Request...\n"
openssl req -config /ca/intermediate/${SIGNER}/openssl.cnf -new -sha256 \
    -key /ca/user/${NAME}/private/key.pem \
    -out /ca/user/${NAME}/csr/csr.pem

printf "${ORANGE}[intermediate]${NO_COLOR} Signing Request From User...\n"
openssl ca -config /ca/intermediate/${SIGNER}/openssl.cnf -extensions user_cert \
    -days 365 -notext -md sha256 \
    -in /ca/user/${NAME}/csr/csr.pem \
    -out /ca/user/${NAME}/certs/cert.pem

printf "${GREEN}[user]${NO_COLOR} Generating Certificate Chain\n"
cp /ca/intermediate/${SIGNER}/certs/ca-chain.cert.pem /ca/user/${NAME}/certs/ca-chain.cert.pem

printf "${GREEN}[user]${NO_COLOR} Complete!\n"
