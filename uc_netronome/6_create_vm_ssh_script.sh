#!/bin/bash

if [ -z "$1" ]; then
 echo "Please specify instance name"
 exit -1
fi

script_dir="$(dirname $(readlink -f $0))"

. $HOME/adminrc 

ip=`openstack server list | awk '/'"$1"'/{print $10}'`

if [ -z "$ip" ]; then
 echo "Instance doesn't exist: $1"
 exit -1
fi


cd $script_dir

rm -rf ssh_to_$1
cat > ssh_to_$1 << EOF
ssh ubuntu@$ip -i markey.pem
EOF

chmod a+x ssh_to_$1
