#!/bin/bash

echo "Detecting linux: "

# Ubuntu
id=`grep ID= /etc/os-release`
if [[ $id == *"ubuntu"* ]]; then
echo "Ubuntu"

apt-get install -y qemu-kvm libvirt-bin virtinst cloud-image-utils

else if [[ $id == *"centos"* ]]; then
echo "CentOS"

yum install -y centos-release-qemu-ev.noarch python-virtinst virt-manager qemu-kvm-ev libvirt libvirt-python virt-install tmux cloud-utils genisoimage

service libvirtd restart

fi

fi



