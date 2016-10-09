#!/bin/sh -e

TEMPLATE=jessie
OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    NETWORK_DEVICE=en0
else
    NETWORK_DEVICE=eth0
fi

usage()
{
    echo "Create a new vagrant box based on a template and start it."
    echo "Usage: [--help][--template TEMPLATE][--device NETWORK_DEVICE] NODE_NAME"
    echo "Default template: ${TEMPLATE}"
    echo "Default network device: ${NETWORK_DEVICE}"
    echo "Example: ${0} --template jessie ldap"
}

while true; do
    case ${1} in
        --help)
            usage

            exit 0
            ;;
        --template)
            TEMPLATE=${2-}
            shift 2
            ;;
        --device)
            NETWORK_DEVICE=${2-}
            shift 2
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
    usage

    exit 1
fi

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    ADDRESS=$(ipconfig getifaddr "${NETWORK_DEVICE}" || true)
else
    ADDRESS=$(ip addr list "${NETWORK_DEVICE}" | grep 'inet ' | cut -d ' ' -f 6 | cut -d / -f 1)
fi

if [ "${ADDRESS}" = "" ]; then
    echo "Could not determine network address."

    exit 1
fi

SCRIPT_DIRECTORY=$(dirname "${0}")
mkdir -p "${SCRIPT_DIRECTORY}/box"
BOX_DIRECTORY="${SCRIPT_DIRECTORY}/box/${NODE_NAME}"

if [ -d "${BOX_DIRECTORY}" ]; then
    echo "Box already exists."

    exit 1
fi

cp -r "${SCRIPT_DIRECTORY}/template/${TEMPLATE}" "${BOX_DIRECTORY}"
cd "${BOX_DIRECTORY}"
echo "${ADDRESS}" > provision/master_address
echo "${NODE_NAME}" > provision/hostname
