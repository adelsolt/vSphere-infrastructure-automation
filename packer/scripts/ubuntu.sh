#!/usr/bin/env bash
# Ubuntu 22.04 post-install runs via packer shell provisioner

set -euo pipefail

apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -q
DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
    build-essential \
    curl \
    git \
    htop \
    open-vm-tools \
    python3 \
    sudo \
    vim \
    wget

timedatectl set-timezone UTC
systemctl enable open-vm-tools

# disabled flag stops modules from running; clean wipes cached instance data
# so the first boot of each clone doesn't stall waiting for a datasource
touch /etc/cloud/cloud-init.disabled
cloud-init clean --logs --seed

# clones must generate their own host keys — shared keys break known_hosts and are a MITM risk
rm -f /etc/ssh/ssh_host_*

# empty machine-id so systemd generates a fresh one on first boot of each clone
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

apt-get autoremove -y -q
apt-get clean -q
rm -rf /var/lib/apt/lists/*
