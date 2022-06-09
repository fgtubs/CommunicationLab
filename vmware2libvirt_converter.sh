#!/bin/sh

# Converting a VMware image to a libvirt image

########################################################
## Make sure that you have all this in your directory ##
#   - the file you want to convert (.vmdx)             #
#   - the file you want to convert (.vmx)              #
#   - the Vagrant file                                 #
########################################################

# Passing the Variables:
# - first Variable = Name of the vmware image (without the ending)
VMWARE_IMAGE=$1".vmdx"
# - second Variable = Name of the .vmx fiel (without ending)
VMWARE_FILE=$2".vmx"


# Generated Outputfiles:
LIBVIRT_IMAGE=$1".qcow2"
LIBVIRT_FILE=$2".xml"


# installing the script to convert .vmx to .xml file (vmware2libvirt)
sudo apt update
sudo  apt install python2
wget https://bazaar.launchpad.net/~ubuntu-virt/virt-goodies/trunk/download/head:/vmware2libvirt
chmod 755 vmware2libvirt
sudo mv -iv vmware2libvirt /usr/local/bin/
############ CHANGE FIRST LINE TO ################
############ #! /usr/bin/env python2.7 ###########


# Converting the image .vmdk (vmware) to .qcow2 
qemu-img convert -f vmdk -O qcow2 outputfile/with/new/ending/here/.qcow2 (wenn im gleichen Ordner gespeichert werden soll einfach nur der Name .qcow2)

# using the script to convert .vmx to .xml file
vmware2libvirt -f $VMWARE_FILE > $LIBVIRT_FILE

# add the .xml file to the box
virsh -c qemu:///system define $LIBVIRT_FILE

# checking if the box was properly converted, read the virtual_size 

V_SIZE=$(qemu-img info Fedora.qcow2 | grep "virtual size" | awk '{print $3}')

# creating the metadata.json file, with the right virtual size
cat << EFO > metadata.json
{
    "provider" : "libvirt",
    "format" : "qcow2",
    "virtual_size" : $V_SIZE
}

