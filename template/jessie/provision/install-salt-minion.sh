#!/bin/sh -e

usage()
{
    echo "Usage: ${0} MASTER_NAME"
}

MASTER_NAME="${1}"

if [ "${MASTER_NAME}" = "" ]; then
    usage

    exit 1
fi

USER_ID=$(id -u)

if [ ! "${USER_ID}" = "0" ]; then
    echo "Must be run as root."

    exit 1
fi

VERSION=$(cut -c 1-1 < /etc/debian_version)
FILE=/etc/apt/sources.list.d/saltstack.list

if [ "${VERSION}" = "6" ]; then
    echo "deb http://debian.saltstack.com/debian squeeze-saltstack main" > "${FILE}"
    BACKPORTS_SOURCE=/etc/apt/sources.list.d/backports.list
    echo "deb http://backports.debian.org/debian-backports squeeze-backports main contrib non-free" > "${BACKPORTS_SOURCE}"
elif [ "${VERSION}" = "7" ]; then
    echo "deb http://debian.saltstack.com/debian wheezy-saltstack main" > "${FILE}"
elif [ "${VERSION}" = "8" ]; then
    echo "deb http://debian.saltstack.com/debian jessie-saltstack main" > "${FILE}"
else
    echo "Unsupported Debian version: ${VERSION}"

    exit 1
fi

wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -
export DEBIAN_FRONTEND="noninteractive"
apt-get update
apt-get -qq install salt-minion
echo "master: ${MASTER_NAME}" > /etc/salt/minion.d/minion.conf
service salt-minion restart
