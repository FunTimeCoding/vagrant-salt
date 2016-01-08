#!/bin/sh -e

BASE_DIRECTORY="/vagrant/provision"
HOST_NAME=$(cat "${BASE_DIRECTORY}/hostname.conf")
"${BASE_DIRECTORY}/hosts-file-update.sh" "${HOST_NAME}"
hostname "${HOST_NAME}"
echo "${HOST_NAME}" > /etc/hostname
SALT_DIRECTORY="/etc/salt"
MINION_CONF_DIRECTORY="${SALT_DIRECTORY}/minion.d"
mkdir -p "${MINION_CONF_DIRECTORY}"
echo "${HOST_NAME}" > "${SALT_DIRECTORY}/minion_id"
MASTER_NAME=$(cat "${BASE_DIRECTORY}/master_address")
"${BASE_DIRECTORY}/install-salt-minion.sh" "${MASTER_NAME}"
