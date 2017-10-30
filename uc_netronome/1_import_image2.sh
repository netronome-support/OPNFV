#!/bin/bash
set -xe

. $HOME/adminrc 
echo "Importing netronome_perf"
IMAGE=netronome_perf2
#openstack image delete $IMAGE
script_dir="$(dirname $(readlink -f $0))"
glance image-create --name $IMAGE  --file $script_dir/netronome_perf.img --disk-format qcow2 --container-format bare --progress --visibility public

openstack image list | grep $IMAGE
