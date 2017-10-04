# OPNFV - performance setup scripts

## 0) Clone this repository locally
```
git clone https://github.com/netronome-support/OPNFV.git
```

## 1) Create weaponized image

Create an image that contains dpdk-apps

>NOTE: Scripts directory: create_image

0_create_netronome_image.sh
```
#!/bin/bash

script_dir="$(dirname $(readlink -f $0))"
IVG_dir="$(echo $script_dir | sed 's/\(IVG\).*/\1/g')"
$IVG_dir/helper_scripts/y_vm_shutdown.sh
IVG_folder/helper_scripts/vm_shutdown_all.sh
$script_dir/0_download_cloud_image.sh
if [ $? == 1 ]
then exit 1
fi
#Download Ubuntu 16 cloud image
$script_dir/1_cloud_init.sh 

#Create Guest machine with this image
$script_dir/2_install_vm.sh

#Copy installation scripts to Guest
$script_dir/3_copy_vm_scripts.sh

#Install dpdk apps on Guest
$script_dir/4_run_vm_scripts.sh

#Copy created image to scripts directory
mv /var/lib/libvirt/images/ubuntu-16.04-server-cloudimg-amd64-disk1.img $script_dir/../uc_netronome/netronome_perf.img 
```

## 2) Copy image and UC scripts to Undercloud


```
#!/bin/bash

mac=`virsh dumpxml undercloud | grep br-admin -B 1 | awk -F "'" 'NR==1 {print $2}'`
ip=`arp -an | awk -F '[()]' '/'$mac'/ {print $2}'`
echo $ip

script_dir="$(dirname $(readlink -f $0))"

scp -r $script_dir/uc_netronome stack@$ip:/home/stack/
```

## 3) Import image into OPNFV
```
#!/bin/bash
. $HOME/adminrc 

script_dir="$(dirname $(readlink -f $0))"
openstack image create "netronome_perf" --disk-format qcow2 \
--container-format bare \
--public --file $script_dir/netronome_perf.img

openstack image list | grep netronome_perf
```

## 4) Create flavor
```
#!/bin/bash

. $HOME/adminrc

openstack flavor create --ram 4096 --disk 8 --vcpus 4 netronome_perf --property hw_cpu_policy=dedicated \
--property hw_cpu_thread_policy=isolate

nova flavor-key netronome_perf set hw:mem_page_size=2048

openstack flavor list | grep netronome_perf
```

## 5) Create VMs using above image

Create Guest machines with the following script:
```
./2_create_opnfv_vm.sh [VM Name] [Availability zone]
```


```
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
#IMAGE=cirros
IMAGE=netronome_perf
#IMAGE=ubuntu_vanilla
NET=selfservice
PORT_NAME=demo_${VNIC_MODE}_$1
INSTANCE_NAME=$1



net_id=`neutron net-show ${NET} | grep "\ id\ " | awk '{ print $4 }'`
port_id0=`neutron port-create $net_id --name ${PORT_NAME}_0 | grep "\ id\ " | awk '{ print $4 }'`
port_id1=`neutron port-create $net_id --name ${PORT_NAME}_1 --binding:vnic_type ${VNIC_MODE} | grep "\ id\ " | awk '{ print $4 }'`

#port_id2=`neutron port-create $net_id --name ${PORT_NAME}_2 --binding:vnic_type ${VNIC_MODE} | grep "\ id\ " | awk '{ print $4 }'`
openstack server create --flavor ${FLAVOR} --image ${IMAGE} --nic port-id=${port_id0} --nic port-id=${port_id1} --security-group default --key markey ${INSTANCE_NAME} --availability-zone nova:overcloud-novacompute-$2.netronome.com

```

## 6) Attach floating IP


## 7) SSH to VMs


## 8) Run dpdk-pktgen

## 9) Configure L2 addresses