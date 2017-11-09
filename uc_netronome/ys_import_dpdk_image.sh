#!/bin/bash
. $HOME/adminrc 
IMAGE=ys_dpdk_cloud
echo "Importing $IMAGE"
script_dir="$(dirname $(readlink -f $0))"
glance image-create --name $IMAGE  --file $script_dir/$IMAGE.img --disk-format qcow2 --container-format bare --progress --visibility public

openstack image list | grep $IMAGE
