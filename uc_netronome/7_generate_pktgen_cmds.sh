#!/bin/bash

if [ -z "$1" ]; then
 echo "Please specify the 2 instances"
 exit -1
fi

if [ -z "$2" ]; then
 echo "Only one instance specified"
 exit -1
fi


echo -----------------------------------
echo Host0: $1
echo -----------------------------------

ip0=`nova interface-list $1 | awk 'NR > 4 {print $8}'`
mac0=`nova interface-list $1 | awk 'NR > 4 {print $10}'`

echo IPv4 address: $ip0
echo MAC address: $mac0
echo -----------------------------------

echo -----------------------------------
echo Host0: $2
echo -----------------------------------

ip1=`nova interface-list $2 | awk 'NR > 4 {print $8}'`
mac1=`nova interface-list $2 | awk 'NR > 4 {print $10}'`

echo IPv4 address: $ip1
echo MAC address: $mac1
echo -----------------------------------


echo -e "-= pktgen commands =- \n
Host0:
set 0 dst mac $mac1
set 0 src ip $ip0/24
set 0 dst ip $ip1

Host1:
set 1 dst mac $mac0
set 1 src ip $ip1/24
set 1 dst ip $ip0
-----------------------------------

"


