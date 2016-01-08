#!/bin/sh -e

BASE=$(dirname "${0}")
TEMPLATE="jessie"
DO_NOT_START=false
OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Linux" ]; then
    ETHERNET_DEVICE="eth0"
elif [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    ETHERNET_DEVICE="en0"
else
    echo "Operating system '${OPERATING_SYSTEM}' not supported."

    exit 1
fi

usage()
{
    echo "Description: This tool helps you create a new vagrant box based on a template and start it."
    echo "Usage: [-a][-d][-h][-e ETHERNET_DEVICE][-t TEMPLATE] NODE_NAME"
    echo "* -a - Only create the box configuration and do not run 'vagrant up'."
    echo "* -d - Enable debug output."
    echo "* -h - Show this message."
    echo "* -t - Default template is ${TEMPLATE}"
    echo "* -e - Default ethernet device is ${ETHERNET_DEVICE}"
    echo "Example: ${0} -d -a -t jessie ldap"
}

while true; do
    case ${1} in
        -h)
            usage

            exit 0
            ;;
        -d)
            set -x
            shift
            ;;
        -t)
            TEMPLATE=${2-}
            shift 2
            ;;
        -e)
            ETHERNET_DEVICE=${2-}
            shift 2
            ;;
        -a)
            DO_NOT_START=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1
NODE_NAME="${1}"
# TODO: NODE_NAME should match ^[a-z][-a-z0-9]*$

if [ "${NODE_NAME}" = "" ]; then
    echo "NODE_NAME not set."
    usage

    exit 1
fi

if [ "${OPERATING_SYSTEM}" = "Linux" ]; then
    MASTER_ADDRESS=$(ip addr list "${ETHERNET_DEVICE}" | grep "inet " | cut -d ' ' -f 6 | cut -d / -f 1)
elif [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    MASTER_ADDRESS=$(ipconfig getifaddr "${ETHERNET_DEVICE}" || true)
fi

if [ "${MASTER_ADDRESS}" = "" ]; then
    echo "Could not determine master address."

    exit 1
fi

mkdir -p "${BASE}/box"
NEW_BOX_DIRECTORY="${BASE}/box/${NODE_NAME}"

if [ -d "${NEW_BOX_DIRECTORY}" ]; then
    echo "Box ${NEW_BOX_DIRECTORY} already exists."

    exit 1
fi

cp -r "${BASE}/template/${TEMPLATE}" "${NEW_BOX_DIRECTORY}"
echo "${MASTER_ADDRESS}" > "${NEW_BOX_DIRECTORY}/provision/master_address"
echo "${NODE_NAME}" > "${NEW_BOX_DIRECTORY}/provision/hostname.conf"

if [ "${DO_NOT_START}" = true ]; then
    echo "Exit due to the -d argument."

    exit 0
fi

cd "${NEW_BOX_DIRECTORY}"
vagrant up
