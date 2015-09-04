#!/bin/sh

BASE="/vagrant/provision"
HOST_NAME=$(cat "${BASE}/hostname.conf")

# configure hosts and hostname
"${BASE}/hosts-file-update.sh" "${HOST_NAME}"
hostname "${HOST_NAME}"
echo "${HOST_NAME}" > /etc/hostname

# create minion configuration
SALT_DIR="/etc/salt"
MINION_CONF_DIR="${SALT_DIR}/minion.d"
mkdir -p "${MINION_CONF_DIR}"
echo "${HOST_NAME}" > "${SALT_DIR}/minion_id"
cp "${BASE}/minion_dev.conf" "${MINION_CONF_DIR}"

# install salt minion
"${BASE}/salt-install-minion.sh"
