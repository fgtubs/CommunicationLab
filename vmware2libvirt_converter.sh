#!/bin/bash

# Converting a VMware image to a libvirt image

########################################################
## Make sure that you have all this in your directory ##
#   - the file you want to convert (.vmdk)             #
#   - the file you want to convert (.vmx)              #
#   - the Vagrant file                                 #
########################################################
cat << EOF
## Make sure that you have all this in your directory ##
#   - the file you want to convert (.vmdk)             #
#   - the file you want to convert (.vmx)              #
#   - the Vagrant file                                 #
EOF

read -p "Are all required file in this directory? [Y/n] " response
if [ $response == 'Y' ] || [ $response == 'y' ]
then
    echo "Ok"
else
    echo "Please make sure that all required files are in the directory"
    exit 1
fi


if [ $1 != "" ]
then
    ENDING=$(echo $1 | tail -c 6) 
    if [ $ENDING == ".vmdk" ]
    then
        echo "Type in file name of the first argument without the ending (without .vmdk)!"
        exit 1
    else 
        echo "First argument passed"
    fi
else
    echo "First argument (the vmware image, without the ending (.vmdk)) is missing"
    exit 1
fi

if [ $2 != "" ]
then
    ENDING2=$(echo $2 | tail -c 5)
    if [ $ENDING2 == ".vmx" ]
    then
        echo "Type in the file name of the second argument without the ending (without .vmx)!"
        exit 1
    else
        echo "Second argument passed"
    fi
else
    echo "Second argument (the vmware config file, without the ending (.vmx)) is missing"
    exit 1
fi

if [ -e Vagrantfile ]
then
    echo "Vagrantfile existing"
else
    echo "Vagrantfile is missing in the directory"
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
LIBVIRT_BOX=$1".box"

# Converting the image .vmdk (vmware) to .qcow2 
echo "converting the .vmdk file to qcow2"
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
echo "..."
echo "Packing the Box for Vagrant ..."
tar cvzf $LIBVIRT_BOX ./metadata.json ./Vagrantfile ./$LIBVIRT_IMAGE
echo "Box packed"


# The Box is added the Vagrant 
echo "Adding the box to Vagrant ..."
vagrant box add --name $1 --provider libvirt $LIBVIRT_BOX
echo "Box added to Vagrant"

echo " "
echo "############ Finished Converting ###########"
echo "Check with: 'vagrant box list' if the box was added succesfully to Vagrant "