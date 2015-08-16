#!/bin/sh

usage(){
    echo "run as root: ${0} some.fqdn"

    exit 1
}

[ "${1}" = "" ] && usage
[ ! "$(id -u)" = "0" ] && usage

VALIDATED=$(echo "${1}" | grep -P '(?=^.{1,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)')

if [ "${VALIDATED}" = "" ]; then
    echo "invalid fqdn"

    exit 1
fi

HOST_NAME=$(echo "${VALIDATED}" | cut -d '.' -f 1)
IP=$(ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')

if [ "${IP}" = "" ]; then
    echo "invalid ip"

    exit 1
fi

if [ "${HOST_NAME}" = "" ]; then
    echo "invalid hostname"

    exit 1
fi

echo "old hosts file:"
cat /etc/hosts

echo "127.0.0.1 localhost" > /etc/hosts
echo "${IP} ${VALIDATED} ${HOST_NAME}" >> /etc/hosts

echo "new hosts file:"
cat /etc/hosts
