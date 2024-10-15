#!/bin/bash
# Ubuntu setup script

# Update and install necessary packages
apt-get update
apt-get upgrade -y
apt-get install -y build-essential curl git

# Clean up
apt-get autoremove -y
apt-get clean
