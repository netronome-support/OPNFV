#!/bin/bash
. $HOME/adminrc

echo "Importing netronome_perf"
script_dir="$(dirname $(readlink -f $0))"

glance image-create --name netronome_perf --file $script_dir/netronome_perf.img --disk-format qcow2 --container-format bare --progress --visibility public

openstack image list | grep netronome_perf
