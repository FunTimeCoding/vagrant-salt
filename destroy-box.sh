#!/bin/sh -e

BOX_NAME="${1}"

if [ "${BOX_NAME}" = "" ]; then
    echo "Usage: BOX_NAME"

    exit 1
fi

if [ ! -d "box/${BOX_NAME}" ]; then
    echo "Box not found."

    exit 1
fi

sudo salt-key --yes --delete "${BOX_NAME}" || true
cd "box/${BOX_NAME}"
vagrant destroy --force
