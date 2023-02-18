#!/bin/bash
set -e

mkdir -p /ca/root
mkdir -p /ca/intermediate
mkdir -p /ca/user
mkdir -p /ca/server

echo "Select the entity you want to create"
PS3="Choice: "
select ENTITY in RootCA IntermediateCA UserCert ServerCert; do
    case $ENTITY in
        RootCA)
            read -p "Choose a name for the directory within /ca/root/: " NAME
            /scripts/root.sh ${NAME}
            break;;
        IntermediateCA)
            if [ -z "$(ls /ca/root/)" ]; then
                echo "IntermediateCA can not be created because there is no RootCA yet."
                break;
            fi
            read -p "Choose a name for the directory within /ca/intermediate/: " NAME
            /scripts/intermediate.sh ${NAME}
            break;;
        UserCert)
            if [ -z "$(ls /ca/intermediate/)" ]; then
                echo "UserCert can not be created because there is no IntermediateCA yet."
                break;
            fi
            read -p "Choose a name for the directory within /ca/user/: " NAME
            /scripts/user.sh ${NAME}
            break;;
        ServerCert)
            if [ -z "$(ls /ca/intermediate/)" ]; then
                echo "ServerCert can not be created because there is no IntermediateCA yet."
                break;
            fi
            read -p "Choose a name for the directory within /ca/server/: " NAME
            /scripts/server.sh ${NAME}
            break;;
        *)
            break;;
    esac
done