#!/bin/sh -e

MASTER_NAME="${1}"

if [ "${MASTER_NAME}" = "" ]; then
    echo "Usage: ${0} MASTER_NAME"

    exit 1
fi

IDENTIFIER=$(id -u)

if [ ! "${IDENTIFIER}" = 0 ]; then
    echo "Must be root."

    exit 1
fi

echo "deb http://repo.saltstack.com/apt/debian/7/amd64/latest wheezy main" > /etc/apt/sources.list.d/saltstack.list
wget --quiet --output-document - https://repo.saltstack.com/apt/debian/8/amd64/latest/SALTSTACK-GPG-KEY.pub | apt-key add -
export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 update
apt-get --quiet 2 install salt-minion
echo "master: ${MASTER_NAME}" > /etc/salt/minion.d/minion.conf
service salt-minion restart
