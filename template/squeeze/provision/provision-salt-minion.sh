#!/bin/sh -e

NAME=$(cat /vagrant/provision/hostname.conf)
/vagrant/provision/hosts-file-update.sh "${NAME}"
hostname "${NAME}"
echo "${NAME}" > /etc/hostname
mkdir -p /etc/salt/minion.d
echo "${NAME}" > /etc/salt/minion_id
ADDRESS=$(cat /vagrant/provision/master_address)
/vagrant/provision/install-salt-minion.sh "${ADDRESS}"
