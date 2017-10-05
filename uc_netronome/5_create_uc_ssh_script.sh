#!/bin/bash

if [ -z "$1" ]; then
 echo "Please specify instance name"
 exit -1
fi

hypervisor=overcloud-novacompute-
script_dir="$(dirname $(readlink -f $0))"

. $HOME/stackrc 


ip=`openstack server list | awk '/'"overcloud-novacompute-$1"'/{print $8}' | cut -d"=" -f2`

if [ -z "$ip" ]; then
 echo "Instance doesn't exist: $1"
 exit -1
fi


cd $script_dir

rm -rf ssh_to_$hypervisor$1
cat > ssh_to_$hypervisor$1 << EOF
ssh heat-admin@$ip
EOF

chmod a+x ssh_to_$hypervisor$1

