#!/bin/sh -e

add_key()
{
    wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -
}

VERSION=$(cut -c 1-1 < /etc/debian_version)

if [ "${VERSION}" = "6" ]; then
    add_key
    echo "deb http://debian.saltstack.com/debian squeeze-saltstack main" > /etc/apt/sources.list.d/saltstack.list
    echo "deb http://backports.debian.org/debian-backports squeeze-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list
elif [ "${VERSION}" = "7" ]; then
    add_key
    echo "deb http://debian.saltstack.com/debian wheezy-saltstack main" > /etc/apt/sources.list.d/saltstack.list
else
    echo "Unknown version: ${VERSION}"

    exit 1
fi

export DEBIAN_FRONTEND="noninteractive"
apt-get update
apt-get -qq install salt-minion
