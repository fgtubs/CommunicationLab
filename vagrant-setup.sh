#!/bin/sh

# Install Vagrant 
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install -y vagrant

# Install KVM
sudo apt install -y qemu qemu-kvm libvirt-clients libvirt-daemon-system virtinst bridge-utils
kvm-ok

# Install libvirt and vagrant plugins
sudo apt install -y qemu libvirt-daemon-system libvirt-clients libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev ruby-libvirt ebtables dnsmasq-base
sudo apt-get install -y build-essential
vagrant plugin install vagrant-libvirt
vagrant plugin install vagrant-mutate

# Install NFS
sudo apt update
sudo apt install -y nfs-kernel-server
