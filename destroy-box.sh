#!/bin/sh -e

BOX_NAME="${1}"

if [ "${BOX_NAME}" = "" ]; then
    echo "Usage: BOX_NAME"

    exit 1
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    salt-key --yes --delete "${BOX_NAME}" || true
else
    sudo salt-key --yes --delete "${BOX_NAME}" || true
fi

if [ -d "box/${BOX_NAME}" ]; then
    cd "box/${BOX_NAME}"
    vagrant destroy --force
fi
