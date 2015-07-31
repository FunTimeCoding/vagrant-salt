#!/bin/sh

BASE="/vagrant/provision"
HOSTNAME=$(cat "${BASE}/hostname.conf")

# configure hosts and hostname
"${BASE}/hosts-file-update.sh" "${HOSTNAME}.dev"
hostname ${HOSTNAME}
echo ${HOSTNAME} > /etc/hostname

# create minion configuration
SALT_DIR="/etc/salt"
MINION_CONF_DIR="${SALT_DIR}/minion.d"
mkdir -p "${MINION_CONF_DIR}"
echo "${HOSTNAME}" > "${SALT_DIR}/minion_id"
cp "${BASE}/minion_dev.conf" "${MINION_CONF_DIR}"

# install salt minion
"${BASE}/salt-install-minion.sh"
