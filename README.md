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

## 2) Copy image to Undercloud


```
#!/bin/bash

mac=`virsh dumpxml undercloud | grep br-admin -B 1 | awk -F "'" 'NR==1 {print $2}'`
ip=`arp -an | awk -F '[()]' '/'$mac'/ {print $2}'`
echo $ip

script_dir="$(dirname $(readlink -f $0))"

scp -r $script_dir/uc_netronome stack@$ip:/home/stack/
```

## 3) Import image into OPNFV


## 4) Create flavor


## 5) Create VMs using above image


## 6) Attach floating IP


## 7) SSH to VMs


## 8) Run dpdk-pktgen

## 9) Configure L2 addresses