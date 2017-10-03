#!/bin/bash

mac=`virsh dumpxml undercloud | grep br-admin -B 1 | awk -F "'" 'NR==1 {print $2}'`
ip=`arp -an | awk -F '[()]' '/'$mac'/ {print $2}'`
echo $ip

script_dir="$(dirname $(readlink -f $0))"

scp -r $script_dir/uc_netronome stack@$ip:/home/stack/

