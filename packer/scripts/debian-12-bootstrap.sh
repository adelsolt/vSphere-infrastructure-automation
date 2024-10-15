#!/bin/bash
# Debian 12 Bootstrap Script

# Update and upgrade system packages
apt-get update
apt-get upgrade -y

# Install essential packages
apt-get install -y build-essential curl wget vim git

# Configure the system
echo "Setting up the system configuration..."

# Set timezone
timedatectl set-timezone Etc/UTC

# Configure APT to use a mirror (if needed)
echo "deb http://deb.debian.org/debian/ bullseye main contrib non-free" > /etc/apt/sources.list

# Clean up
apt-get autoremove -y
apt-get clean

echo "Bootstrap process complete."
