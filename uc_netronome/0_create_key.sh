#!/bin/bash
. $HOME/adminrc

script_dir="$(dirname $(readlink -f $0))"

cd $script_dir

if [ -f markey.pem ]; then
        echo -e "${GREEN}markey.pem already exists${NC}"
	echo "Exiting"
	exit 1	
fi

exists=`openstack keypair list | grep markey`

if [ ! -z "$exists" ]; then
        echo -e "${GREEN}markey already exists${NC}"
	echo "Exiting"	
        exit 1
fi


openstack keypair create markey > markey.pem
chmod 600 markey.pem
openstack keypair list

