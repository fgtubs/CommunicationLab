#!/bin/sh

# Converting a VMware image to a libvirt image

########################################################
## Make sure that you have all this in your directory ##
#   - the file you want to convert (.vmdx)             #
#   - the file you want to convert (.vmx)              #
#   - the Vagrant file                                 #
########################################################

if [ $1 != "" ]
then
    echo "First argument passed"
else
    echo "First argument (the vmware image, without the ending (.vmdk)) is missing"
    exit 1
fi

if [ $2 != "" ]
then
    echo "Second argument passed"
else
    echo "First argument (the vmware image, without the ending (.vmdk)) is missing"
    exit 1
fi

if [ -e Vagrantfile ]
then
    echo "Vagrantfile existing"
else
    echo "Vagrantfile is missing"
    exit 1
fi

# Passing the Variables:
# - first Variable = Name of the vmware image (without the ending)
VMWARE_IMAGE=$1".vmdk"
echo $VMWARE_IMAGE
# - second Variable = Name of the .vmx fiel (without ending)
VMWARE_FILE=$2".vmx"
echo $VMWARE_FILE


# Generated Outputfiles:
LIBVIRT_IMAGE=$1".qcow2"
LIBVIRT_FILE=$2".xml"
LIBVIRT_BOX=$2"_box.box"

# installing the script to convert .vmx to .xml file (vmware2libvirt)
sudo apt update
sudo  apt install python2
wget https://bazaar.launchpad.net/~ubuntu-virt/virt-goodies/trunk/download/head:/vmware2libvirt
chmod 755 vmware2libvirt
sudo mv -iv vmware2libvirt /usr/local/bin/
############ CHANGE FIRST LINE TO ################
############ #! /usr/bin/env python2.7 ###########


# Converting the image .vmdk (vmware) to .qcow2 
qemu-img convert -f vmdk -O qcow2 $VMWARE_IMAGE $LIBVIRT_IMAGE
echo "converted to .qcow2 file" 

# using the script to convert .vmx to .xml file
vmware2libvirt -f $VMWARE_FILE > $LIBVIRT_FILE
echo "converted to .xml file"

# add the .xml file to the box
virsh -c qemu:///system define $LIBVIRT_FILE
echo "added to Libvirt"

# checking if the box was properly converted, read the virtual_size 

V_SIZE=$(qemu-img info $LIBVIRT_IMAGE | grep "virtual size" | awk '{print $3}')

# creating the metadata.json file, with the right virtual size
cat << EOF > metadata.json
{
    "provider" : "libvirt",
    "format" : "qcow2",
    "virtual_size" : $V_SIZE
}
EOF

# Packing all Files together that are needed to add this box to Vagrant
echo "Packing the Box for Vagrant ..."
tar cvzf $LIBVIRT_BOX ./metadata.json ./Vagrantfile ./$LIBVIRT_IMAGE
echo "Box packed"


# The Box is added the Vagrant 
echo "Adding the box to Vagrant ..."
vagrant box add --name $LIBVIRT_BOX --provider libvirt $LIBVIRT_BOX
echo "Box added to Vagrant"