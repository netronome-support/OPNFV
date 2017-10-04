#!/bin/bash

if [ -z "$1" ]; then
 echo "Please specify vm name"
 exit -1
fi

. $HOME/adminrc 

flo_id=`openstack floating ip create external | awk '/floating_ip/{print $4}'`
openstack server add floating ip $1 $flo_id

openstack server list | grep $1
