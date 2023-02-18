#!/bin/bash

RED="\033[0;31m"
NO_COLOR="\033[0m"

NAME=$1
set -e

printf "${RED}[root]${NO_COLOR} Preparing Directories...\n"
mkdir -p /ca/root/${NAME}/private
mkdir -p /ca/root/${NAME}/certs
mkdir -p /ca/root/${NAME}/crl
mkdir -p /ca/root/${NAME}/newcerts
mkdir -p /ca/root/${NAME}/index.txt
echo 1000 > /ca/root/${NAME}/serial

cat /conf/openssl.cnf \
    | sed "s#{{ dir }}#/ca/root/${NAME}#g" \
    | sed "s#{{ policy }}#policy_strict#g" \
    >> /ca/root/${NAME}/openssl.cnf

printf "${RED}[root]${NO_COLOR} Generating Private Key...\n"
openssl genrsa -aes256 \
    -out /ca/root/${NAME}/private/key.pem 2> /dev/null

printf "${RED}[root]${NO_COLOR} Generating Certificate...\n"
openssl req -config /ca/root/${NAME}/openssl.cnf \
    -new -x509 -days 3650 -sha256 -extensions v3_root_ca \
    -key /ca/root/${NAME}/private/key.pem \
    -out /ca/root/${NAME}/certs/cert.pem

printf "${RED}[root]${NO_COLOR} Complete!\n"
