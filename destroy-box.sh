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

SCRIPT_DIRECTORY=$(dirname "${0}")

if [ -d "${SCRIPT_DIRECTORY}/box/${BOX_NAME}" ]; then
    cd "${SCRIPT_DIRECTORY}/box/${BOX_NAME}"
    vagrant destroy --force
fi
