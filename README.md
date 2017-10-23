# OPNFV - performance setup scripts

## 1) Clone this repository locally on the Jumphost
```
git clone https://github.com/netronome-support/OPNFV.git
cd OPNFV
```

## 2) Create weaponized image

* Install virtualization dependencies
```
./0_install_virtualization_deps.sh
```
* Create an image which contains dpdk-apps

>NOTE: Individual scripts directory: create_image
```
./1_create_netronome_image.sh
```
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

## 3) Copy the newly created image(netronome_perf.img) and UC scripts to the Undercloud

```
./2_copy_files.sh
```
```
#!/bin/bash

ip=`virsh net-dhcp-leases default | awk '/undercloud/ {print $5}' | cut -d"/" -f1`
echo "Copying uc_netronome to $ip:/home/stack/"

script_dir="$(dirname $(readlink -f $0))"

scp -r $script_dir/uc_netronome stack@$ip:/home/stack/
```

## 4) Log into Undercloud and browse to script directory
```
./3_login_undercloud.sh
cd uc_netronome
```
You will find the weaponized image along with some uc scripts here:
```
# ls

0_create_key.sh    2_create_flavor.sh    4_attach_floating_ip.sh    6_create_vm_ssh_script.sh
1_import_image.sh  3_create_opnfv_vm.sh  5_create_uc_ssh_script.sh  netronome_perf.img
```


## 5) Create key pair
```
./0_create_key.sh

+--------+-------------------------------------------------+
| Name   | Fingerprint                                     |
+--------+-------------------------------------------------+
| markey | 11:b6:6f:06:6a:c1:90:e6:a1:eb:91:ed:ce:dc:cd:1f |
+--------+-------------------------------------------------+


```

## 6) Import image into OPNFV
```
./1_import_image.sh
```
```
#!/bin/bash
. $HOME/adminrc

echo "Importing netronome_perf"
script_dir="$(dirname $(readlink -f $0))"

glance image-create --name netronome_perf --file $script_dir/netronome_perf.img --disk-format qcow2 --container-format bare --progress --visibility public

openstack image list | grep netronome_perf

```

## 7) Create flavor
```
./2_create_flavor.sh
```
```
#!/bin/bash

. $HOME/adminrc

openstack flavor create --ram 4096 --disk 8 --vcpus 4 netronome_perf --property hw_cpu_policy=dedicated \
--property hw_cpu_thread_policy=isolate

nova flavor-key netronome_perf set hw:mem_page_size=2048

openstack flavor list | grep netronome_perf
```

## 8) Create OPNFV instances using imported image

> NOTE: Ensure that the hypervisor generic name matches variable specified in script(3_create_opnfv_vm.sh)
```
nova hypervisor-list
```
* Create Guest machines with the following script:
```
#usage
./3_create_opnfv_vm.sh [VM Name] [Availability zone]

#example
./3_create_opnfv_vm.sh vm0 0
./3_create_opnfv_vm.sh vm1 1
```


```
#!/bin/bash

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
IMAGE=netronome_perf
#IMAGE=ubuntu_vanilla
NET=selfservice
PORT_NAME=demo_${VNIC_MODE}_$1
INSTANCE_NAME=$1



net_id=`neutron net-show ${NET} | grep "\ id\ " | awk '{ print $4 }'`
port_id0=`neutron port-create $net_id --name ${PORT_NAME}_0 | grep "\ id\ " | awk '{ print $4 }'`
port_id1=`neutron port-create $net_id --name ${PORT_NAME}_1 --binding:vnic_type ${VNIC_MODE} | grep "\ id\ " | awk '{ print $4 }'`

openstack server create --flavor ${FLAVOR} --image ${IMAGE} --nic port-id=${port_id0} --nic port-id=${port_id1} --security-group default --key markey ${INSTANCE_NAME} --availability-zone nova:$HYPERVISOR$2.netronome.com

```

* Wait for instances to boot

```
watch -d openstack server list
```

## 9) Attach floating IP

* Attach floating IP to enable access from external network

```
#usage
./4_attach_floating_ip.sh [Instance name]

#example
./4_attach_floating_ip.sh vm0
./4_attach_floating_ip.sh vm1
```

```
#!/bin/bash

if [ -z "$1" ]; then
 echo "Please specify vm name"
 exit -1
fi

. $HOME/adminrc 

flo_id=`openstack floating ip create external | awk '/floating_ip/{print $4}'`
openstack server add floating ip $1 $flo_id

openstack server list | grep $1

```

## 10) Configure VM vCPU pinning

* Create compute SSH scripts
```
#usage
5_create_uc_ssh_script.sh [Zone ID]

#example
5_create_uc_ssh_script.sh 0
5_create_uc_ssh_script.sh 1
```
* Connect to computes
```
ssh_to_overcloud-novacompute-0
ssh_to_overcloud-novacompute-1
```

* Determine NUMA node linked to card
```
for card in /sys/bus/pci/drivers/nfp/0*; do
    address=`basename $card`
    echo "Agilio address: $address"
    echo -n "NUMA node: "; cat $card/numa_node
    echo -n "Local CPUs: "; cat $card/local_cpulist
done
```

* Display current pinning
```
sudo -i
virsh list

#example output:

 Id    Name                           State
----------------------------------------------------
 21    instance-000000d7              running

#display pinning of instance
virsh vcpupin 21

#pin  vCPUs if required
virsh vcpupin 21 [vcpu] [cpu]

#example
virsh vcpupin 21 0 3
virsh vcpupin 21 1 4
virsh vcpupin 21 2 5
virsh vcpupin 21 3 6
```


## 11) SSH to VMs

* Create VM SSH scripts using
```
#usage
./6_create_vm_ssh_script [Instance name]

#example
./6_create_vm_ssh_script vm0
./6_create_vm_ssh_script vm1
```

```
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
```

New ssh_to*.sh script files should be created in the script directory. Execute the scripts to connect to the respective VMs.
```
./ssh_to_vm0
./ssh_to_vm1
```

> NOTE: If you see the following message
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
...
Offending ECDSA key in /home/stack/.ssh/known_hosts:10
...

```
Delete the existing host key with the following command:
```
sed -i 10d ~/.ssh/known_hosts
```

# dpdk-pktgen

Once in the VM, switch to root and navigate to the DPDK-pktgen folder.

```
sudo -i
cd vm_scripts/samples/DPDK-pktgen/
```

Assign hugepages and bind the igb_uio driver to the Netronome interfaces.
```
./1_configure_hugepages.sh
./2_auto_bind_igb_uio.sh
```



## 12) Configure and Launch pktgen

* Configure pktgen
>**Note:** Default configuration assumes a single port and pins distinct CPUs to TX and RX queues

Modify the following parameters when using more ports(For maximum performance pin distinct CPUs to all TX and RX queues):
```
vi 3_run_dpdk-pktgen.sh
```

In this example we'll assume **two** ports, hence **(2 x (TX + RX)) four** packet queues. The first CPU assigned to pktgen is used for basic program features and is **not** to be assigned to any of the queues.

We therefore require 5 CPUs to cater for two ports:
```
#Specify total number of cores
lcores="-l 1-5"

#Map cores to queues
mapping="-m [2:3].0 -m [4:5].1"
```


* Launch pktgen
```
./3_run_dpdk-pktgen.sh
```

>**Note:** Ensure distinct queue mapping for maximum performance
```
=== port to lcore mapping table (# lcores 5) ===
   lcore:    1       2       3       4       5      Total
port   0: ( D: T) ( 1: 0) ( 0: 1) ( 0: 0) ( 0: 0) = ( 1: 1)
port   1: ( D: T) ( 0: 0) ( 0: 0) ( 1: 0) ( 0: 1) = ( 1: 1)
Total   : ( 0: 0) ( 1: 0) ( 0: 1) ( 1: 0) ( 0: 1)
```

## 13) Configure L2 addresses

Configure destination L2 addresses - This script will help with that
```
./7_generate_pktgen_cmds.sh7_generate_pktgen_cmds.sh vm0 vm1
```

Example output
```
-----------------------------------
Host0: vm0
-----------------------------------
IPv4 address: 192.168.42.23
MAC address: fa:16:3e:68:94:ca
-----------------------------------
-----------------------------------
Host1: vm1
-----------------------------------
IPv4 address: 192.168.42.36
MAC address: fa:16:3e:bd:36:91
-----------------------------------
-= pktgen commands =-

Host0:
set 0 dst mac fa:16:3e:bd:36:91
set 0 src ip 192.168.42.23/24
set 0 dst ip 192.168.42.36

Host1:
set 0 dst mac fa:16:3e:68:94:ca
set 0 src ip 192.168.42.36/24
set 0 dst ip 192.168.42.23
-----------------------------------

```
## 14) Generating traffic in pktgen

* To start generating traffic on ports
```
start [port number]

e.g.
start 0
start all
```

* To stop generating traffic on ports
```
stop [port number]

e.g.
stop 0
stop all
```


## 15) pktgen parameters

* Packet size
```
set [port number] size [packet size]

e.g.
set 0 size 700
set all size 64
```
> **Note:** It's advised to restart traffic generation to apply new packet size
```
stop 0
start 0
```

# Performance tuning

## Pin Virtual CPUs

* Determine instance name on hypervisor
```
# openstack server show [instance name] | grep "instance_name\|hypervisor"
e.g.
# openstack server show **vm6** | grep "instance_name\|hypervisor"
| OS-EXT-SRV-ATTR:hypervisor_hostname  | overcloud-novacompute-1.netronome.com                                 |
| OS-EXT-SRV-ATTR:instance_name        | instance-000001a6 
```

* SSH to hypervisor with respective instance
```
./5_create_uc_ssh_script.sh 0
ssh_to_overcloud-novacompute-0
```

* Pin CPUs
```
# virsh list
 Id    Name                           State
----------------------------------------------------
 100   instance-000001a6              running

# virsh vcpupin 100
VCPU: CPU Affinity
----------------------------------
   0: 2-5,14-17
   1: 2-5,14-17
   2: 2-5,14-17

# pin CPUs
# virsh vcpupin [instance_name] [Virtual CPU] [CPU]

e.g.
virsh vcpupin 100 0 2
virsh vcpupin 100 1 3
...
```

* Login to 

# Troubleshooting

* Ensure the computes have enough free hugepages

```
cat /proc/meminfo | grep -i huge
```

* Ensure Agilio bus matches nova configuration

```
vi /etc/nova/nova.conf
```

* To generate new whitelisting line

```
agilio-vf-mgr.py --genwl >> /etc/nova/nova.conf
service openstack-nova-compute restart
```

* Delete all instances 

```
openstack server list --all | awk 'NR>2{print $2}' | xargs -Iz openstack server delete z
```

* Display instance interfaces
```
nova interface-list [instance name]
```














