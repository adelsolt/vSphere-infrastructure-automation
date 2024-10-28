#!/bin/bash
# CentOS 7 Bootstrap Script

# Update system packages
yum -y update

# Install essential packages
yum -y install gcc make curl wget vim git

# Configure the system
echo "Setting up the system configuration..."

# Set timezone to UTC
timedatectl set-timezone UTC

# Clean up
yum clean all

echo "Bootstrap process complete."
