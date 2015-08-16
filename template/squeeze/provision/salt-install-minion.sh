#!/bin/sh

add_key () {
    wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -
}

VERSION=$(cut -d ' ' -f 3 < /etc/issue)

if [ "${VERSION}" = "6.0" ]; then
    add_key
    echo "deb http://debian.saltstack.com/debian squeeze-saltstack main" > /etc/apt/sources.list.d/saltstack.list
    echo "deb http://backports.debian.org/debian-backports squeeze-backports main contrib non-free" > /etc/apt/sources.list.d/backports.list
elif [ "${VERSION}" = "7" ]; then
    add_key
    echo "deb http://debian.saltstack.com/debian wheezy-saltstack main" > /etc/apt/sources.list.d/saltstack.list
elif [ "${VERSION}" = "jessie/sid" ]; then
    add_key
    echo "deb http://debian.saltstack.com/debian unstable main" > /etc/apt/sources.list.d/saltstack.list
else
    echo "Unknown Debian release: ${VERSION}. Aborting."
    exit 1
fi

apt-get update
apt-get install -y salt-minion
