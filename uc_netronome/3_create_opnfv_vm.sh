#!/bin/bash

#This script demonstrates how to start an instance with an accelerated port.
#This happens as follows:
# 1. The neutron network ID is determined for the tenant selfservice network.
# 2. A neutron port is created on that network. The VNIC binding on that port
#    is set to the desired type of acceleration:
#    - direct for SR-IOV/IOMMU passthrough
#      (guest uses nfp_net driver)
#    - virtio-forwarder for SR-IOV/XVIO relay
#      (guest uses virtio driver)
#    - normal
#      (no acceleration)
# 3. The instance is spawned, with the desired port attached.

if [ -z "$1" ]; then
 echo "Please specify vm name"
 exit -1
fi

if [ -z "$2" ]; then
 echo "Please specify availability zone"
 exit -1
fi

set -xe

. $HOME/adminrc

#VNIC_MODE=direct
#VNIC_MODE=virtio-forwarder
VNIC_MODE=direct
FLAVOR=netronome_perf
HYPERVISOR=overcloud-novacompute-
#IMAGE=cirros
#IMAGE=ubuntu16_4.4_nfp_dpdk
#IMAGE=ubuntu16_dpdk
IMAGE=netronome_perf
#IMAGE=ubuntu_vanilla
NET=selfservice
PORT_NAME=demo_${VNIC_MODE}_$1
INSTANCE_NAME=$1



net_id=`neutron net-show ${NET} | grep "\ id\ " | awk '{ print $4 }'`
port_id0=`neutron port-create $net_id --name ${PORT_NAME}_0 | grep "\ id\ " | awk '{ print $4 }'`
port_id1=`neutron port-create $net_id --name ${PORT_NAME}_1 --binding:vnic_type ${VNIC_MODE} | grep "\ id\ " | awk '{ print $4 }'`
port_id2=`neutron port-create $net_id --name ${PORT_NAME}_2 --binding:vnic_type ${VNIC_MODE} | grep "\ id\ " | awk '{ print $4 }'`

openstack server create --flavor ${FLAVOR} --image ${IMAGE} --nic port-id=${port_id0} --nic port-id=${port_id1} --nic port-id=${port_id2} --security-group default --key markey ${INSTANCE_NAME} --availability-zone nova:$HYPERVISOR$2.netronome.com


openstack server list | grep $INSTANCE_NAME

