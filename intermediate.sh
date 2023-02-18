#!/bin/bash

RED="\033[0;31m"
ORANGE="\033[0;33m"
NO_COLOR="\033[0m"

NAME=$1
set -e

echo "Select RootCA for signing"
PS3="Choice: "
select file in $(ls /ca/root/); do
    if [[ -z $file ]]; then
        echo 'Invalid choice, exiting.' >&2
        exit;
    else
        SIGNER=$file
        break
    fi
done

printf "${ORANGE}[intermediate]${NO_COLOR} Preparing Directories...\n"
mkdir -p /ca/intermediate/${NAME}/private
mkdir -p /ca/intermediate/${NAME}/certs
mkdir -p /ca/intermediate/${NAME}/crl
mkdir -p /ca/intermediate/${NAME}/csr
mkdir -p /ca/intermediate/${NAME}/newcerts
mkdir -p /ca/intermediate/${NAME}/index.txt
echo 1000 > /ca/intermediate/${NAME}/serial
echo 1000 > /ca/intermediate/${NAME}/crlnumber

cat /conf/openssl.cnf \
    | sed "s#{{ dir }}#/ca/intermediate/${NAME}#g" \
    | sed "s#{{ policy }}#policy_loose#g" \
    >> /ca/intermediate/${NAME}/openssl.cnf

printf "${ORANGE}[intermediate]${NO_COLOR} Generating Private Key...\n"
openssl genrsa -aes256 \
-out /ca/intermediate/${NAME}/private/key.pem 2> /dev/null

printf "${ORANGE}[intermediate]${NO_COLOR} Generating Certificate Signing Request...\n"
openssl req -config /ca/intermediate/${NAME}/openssl.cnf -new -sha256 \
    -key /ca/intermediate/${NAME}/private/key.pem \
    -out /ca/intermediate/${NAME}/csr/csr.pem

printf "${RED}[root]${NO_COLOR} Signing Request From Intermediate...\n"
openssl ca -config /ca/root/${SIGNER}/openssl.cnf -extensions v3_intermediate_ca \
    -days 3650 -notext -md sha256 \
    -in /ca/intermediate/${NAME}/csr/csr.pem \
    -out /ca/intermediate/${NAME}/certs/cert.pem

printf "${ORANGE}[intermediate]${NO_COLOR} Generating Certificate Chain\n"
cat /ca/intermediate/${NAME}/certs/cert.pem /ca/root/${SIGNER}/certs/cert.pem > /ca/intermediate/${NAME}/certs/ca-chain.cert.pem

printf "${ORANGE}[intermediate]${NO_COLOR} Complete!\n"
