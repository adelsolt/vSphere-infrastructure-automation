#!/usr/bin/env bash
# CentOS Stream 9 post-install, runs via packer shell provisioner

set -euo pipefail

dnf -y update
dnf -y install \
    curl \
    git \
    gcc \
    make \
    open-vm-tools \
    perl \
    python3 \
    sudo \
    vim-enhanced \
    wget
# perl: runtime dep of open-vm-tools, skip it and VMware Tools reports "not running"
# in vCenter, which breaks guest customization during terraform clone

timedatectl set-timezone UTC
systemctl enable vmtoolsd

# permissive so Ansible can write to system paths without SELinux denials
# still logs what would've been blocked, safer than disabling outright
setenforce 0 2>/dev/null || true
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# clones must generate their own host keys, shared keys break known_hosts and are a MITM risk
rm -f /etc/ssh/ssh_host_*

# empty machine-id so systemd generates a fresh one on first boot of each clone
truncate -s 0 /etc/machine-id

systemctl disable kdump 2>/dev/null || true

dnf clean all
rm -rf /var/cache/dnf
