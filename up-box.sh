#!/bin/sh -e

BOX_NAME="${1}"

if [ "${BOX_NAME}" = "" ]; then
    echo "Usage: BOX_NAME"

    exit 1
fi

SCRIPT_DIRECTORY=$(dirname "${0}")

if [ ! -d "${SCRIPT_DIRECTORY}/box/${BOX_NAME}" ]; then
    echo "Box not found."

    exit 1
fi

cd "${SCRIPT_DIRECTORY}/box/${BOX_NAME}"
vagrant up
sleep 10
SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    salt-key --yes --accept "${BOX_NAME}"
else
    sudo salt-key --yes --accept "${BOX_NAME}"
fi
