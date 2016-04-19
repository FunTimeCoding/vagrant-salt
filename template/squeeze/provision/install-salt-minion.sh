#!/bin/sh -e

USER_ID=$(id --user)

if [ ! "${USER_ID}" = "0" ]; then
    echo "Must be run as root."

    exit 1
fi

MASTER_NAME="${1}"

if [ "${MASTER_NAME}" = "" ]; then
    echo "Usage: ${0} MASTER_NAME"

    exit 1
fi

echo "deb http://debian.saltstack.com/debian squeeze-saltstack main" > /etc/apt/sources.list.d/saltstack.list
echo "deb http://archive.debian.org/debian-backports squeeze-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list
wget --quiet --output-document - "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -
export DEBIAN_FRONTEND="noninteractive"
apt-get -qq update
apt-get -qq install salt-minion
echo "master: ${MASTER_NAME}" > /etc/salt/minion.d/minion.conf
sleep 1
killall salt-minion
sleep 1
service salt-minion restart
