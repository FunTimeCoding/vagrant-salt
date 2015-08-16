#!/bin/sh -e

DEFAULT_TEMPLATE="wheezy"

BASE=$(dirname "${0}")
MINION_ID=""
TEMPLATE="${DEFAULT_TEMPLATE}"
DO_NOT_START=0

usage()
{
    echo "Description: This tool helps you create a new vagrant box based on a template and start it."
    echo "Important: Minion names should only contain a-z and - to avoid minion_id and hostname issues."
    echo "Usage:"
    echo "-i NAME      - Pass the name of the new minion to create."
    echo "-t TEMPLATE  - Pick a different template from the template directory."
    echo "-d           - Don't run 'vagrant up', just create the box configuration."
    echo "-h|-?        - Print this message."
    echo "-v           - Enable verbose output."
}

while getopts "h?vi:dt:" OPT; do
    case "$OPT" in
        h|\?)
            usage
            exit 0
            ;;
        v)
            set -x
            ;;
        t)
            TEMPLATE=$OPTARG
            ;;
        i)
            MINION_ID=$OPTARG
            ;;
        d)
            DO_NOT_START=1
            ;;
    esac
done

if [ "${MINION_ID}" = "" ]; then
    echo "New box name not set."
    usage
    exit 1
fi

OS=$(uname)
if [ "${OS}" = "Linux" ]; then
    MASTER_IP=$(LANG=C ifconfig eth0 | grep "inet addr:" | sed -E 's/^.*inet addr:(10.0.0.[0-9\.]*) .*$/\1/gi')
elif [ "${OS}" = "Darwin" ]; then
    MASTER_IP=$(ipconfig getifaddr en0 || true)
    if [ "${MASTER_IP}" = "" ]; then
        MASTER_IP=$(ipconfig getifaddr en1 || true)
    fi
else
    echo "Operating system '${OS}' unknown."
    exit 1
fi

if [ "${MASTER_IP}" = "" ]; then
    echo "Could not determine master IP."
    exit 1
fi

mkdir -p "${BASE}/box"
NEW_BOX_DIR="${BASE}/box/${MINION_ID}"
if [ -d "${NEW_BOX_DIR}" ]; then
    echo "Box ${NEW_BOX_DIR} already exists."
    exit 1
fi

NEW_BOX_TEMPLATE="${BASE}/template/${TEMPLATE}"
cp -r "${NEW_BOX_TEMPLATE}" "${NEW_BOX_DIR}"

MINION_CONF="${NEW_BOX_DIR}/provision/minion_dev.conf"
echo "master: ${MASTER_IP}" > "${MINION_CONF}"

HOSTNAME_CONF="${NEW_BOX_DIR}/provision/hostname.conf"
echo "${MINION_ID}" > "${HOSTNAME_CONF}"

if [ "${DO_NOT_START}" = "1" ]; then
    echo "Exiting now due to the -d argument."
    exit 0
fi

cd "${NEW_BOX_DIR}"
vagrant up
