#!/bin/bash

if [ -z "$1" ]; then
 echo "Please specify instance name"
 exit -1
fi

instance=$1
script_dir="$(dirname $(readlink -f $0))"

. $HOME/adminrc 

echo "Determining number of NICs.. "
num_nics=$((`nova interface-list $instance | wc -l` - 4))
echo "Found $num_nics"
num_nics=$((num_nics+8))
ip=`openstack server list | awk '/'"$instance"'/{print $'"$num_nics"'}'`

echo "Public IP: $ip"

if [ -z "$ip" ]; then
 echo "Instance doesn't exist: $instance"
 exit -1
fi


cd $script_dir

rm -rf ssh_to_$instance
cat > ssh_to_$instance << EOF
ssh ubuntu@$ip -i markey.pem
EOF

chmod a+x ssh_to_$instance
