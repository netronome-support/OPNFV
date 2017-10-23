#!/bin/bash
. $HOME/adminrc 
echo "Importing netronome_perf"
script_dir="$(dirname $(readlink -f $0))"
glance image-create --name ubuntu16_4.4_nfp_dpdk  --file $script_dir/ubuntu16_4.4_nfp_dpdk.img --disk-format qcow2 --container-format bare --progress --visibility public

openstack image list | grep netronome_perf
