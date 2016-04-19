#!/bin/sh -e

USER_ID=$(id --user)

if [ ! "${USER_ID}" = "0" ]; then
    echo "Run as root."

    exit 1
fi

FULLY_QUALIFIED_DOMAIN_NAME="${1}"

if [ "${FULLY_QUALIFIED_DOMAIN_NAME}" = "" ]; then
    echo "Usage: ${0} FULLY_QUALIFIED_DOMAIN_NAME"

    exit 1
fi

echo "${FULLY_QUALIFIED_DOMAIN_NAME}" | grep --quiet --perl-regexp '(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)' && VALID=true || VALID=false

if [ "${VALID}" = false ]; then
    echo "Invalid name."

    exit 1
fi

HOST_NAME=$(echo "${FULLY_QUALIFIED_DOMAIN_NAME}" | cut --delimiter '.' --fields 1)

if [ "${HOST_NAME}" = "" ]; then
    echo "Could not determine the hostname."

    exit 1
fi

ADDRESS=$(ifconfig eth0 | grep 'inet addr:' | cut --delimiter ':' --fields 2 | awk '{ print $1 }' || true)

if [ "${ADDRESS}" = "" ]; then
    echo "Could not determine the address."

    exit 1
fi

echo "Old hosts file:"
cat /etc/hosts
echo "127.0.0.1 localhost" > /etc/hosts
echo "${ADDRESS} ${FULLY_QUALIFIED_DOMAIN_NAME} ${HOST_NAME}" >> /etc/hosts
echo "New hosts file:"
cat /etc/hosts
