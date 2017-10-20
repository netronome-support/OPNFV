#!/bin/bash

if [ -z "$1" ]; then
 echo "Please specify the 2 instances"
 exit -1
fi

if [ -z "$2" ]; then
 echo "Only one instance specified"
 exit -1
fi

instance1=$1
instance2=$2

. $HOME/adminrc

echo "Determining number of NICs.. "
num_nics=$((`nova interface-list $instance1 | wc -l` - 4))
echo "Found $num_nics"
num_nics=$((num_nics+8))


echo -----------------------------------
echo Host0: $instance1
echo -----------------------------------

ip0=`openstack server list | awk '/'"$instance1"'/{print $9}' | cut -d',' -f1`
mac0=`nova interface-list $instance1 | awk '/'"$ip0"'/ {print $10}'`

ip1=`openstack server list | awk '/'"$instance1"'/{print $10}' | cut -d',' -f1`
mac1=`nova interface-list $instance1 | awk '/'"$ip1"'/ {print $10}'`

echo Interface#0
echo IPv4 address: $ip0
echo MAC address: $mac0

echo Interface#1
echo IPv4 address: $ip1
echo MAC address: $mac1


echo -----------------------------------

echo -----------------------------------
echo Host1: $instance2
echo -----------------------------------

ip2=`openstack server list | awk '/'"$instance2"'/{print $9}' | cut -d',' -f1`
mac2=`nova interface-list $instance2 | awk '/'"$ip2"'/ {print $10}'`

ip3=`openstack server list | awk '/'"$instance2"'/{print $10}' | cut -d',' -f1`
mac3=`nova interface-list $instance2 | awk '/'"$ip3"'/ {print $10}'`

echo Interface#2
echo IPv4 address: $ip2
echo MAC address: $mac2

echo Interface#3
echo IPv4 address: $ip3
echo MAC address: $mac3

echo -----------------------------------


echo -e "-= pktgen commands =- \n
Host0:
set 0 dst mac $mac2
set 0 src ip $ip0/24
set 0 dst ip $ip2

set 1 dst mac $mac3
set 1 src ip $ip1/24
set 1 dst ip $ip3


Host1:
set 0 dst mac $mac0
set 0 src ip $ip2/24
set 0 dst ip $ip0

set 1 dst mac $mac1
set 1 src ip $ip3/24
set 1 dst ip $ip1


-----------------------------------

"


