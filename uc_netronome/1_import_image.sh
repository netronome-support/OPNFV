#!/bin/bash
. $HOME/adminrc 

script_dir="$(dirname $(readlink -f $0))"
openstack image create "netronome_perf" --disk-format qcow2 \
--container-format bare \
--public --file $script_dir/netronome_perf.img

openstack image list | grep netronome_perf
