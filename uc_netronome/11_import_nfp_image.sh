#!/bin/bash
. $HOME/adminrc 
IMAGE=ys_dpdk_nfp.img #ubuntu16_k4.4_nfp.img
echo "Importing $IMAGE"
script_dir="$(dirname $(readlink -f $0))"
glance image-create --name ubuntu16_4.4_nfp_dpdk --file $script_dir/$IMAGE --disk-format qcow2 --container-format bare --progress --visibility public

openstack image list | grep ubuntu16_nfp
