#!/usr/bin/env bash
# Debian 12 post-install, runs via packer shell provisioner

set -euo pipefail

# write sources before the first apt-get, so the update pulls from the right place
cat > /etc/apt/sources.list << 'EOF'
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

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

# clones must generate their own host keys, shared keys break known_hosts and are a MITM risk
rm -f /etc/ssh/ssh_host_*

# empty machine-id so systemd generates a fresh one on first boot of each clone
# skip this and every clone gets the same DHCP lease
truncate -s 0 /etc/machine-id
rm -f /var/lib/dbus/machine-id
ln -sf /etc/machine-id /var/lib/dbus/machine-id

apt-get autoremove -y -q
apt-get clean -q
rm -rf /var/lib/apt/lists/*
