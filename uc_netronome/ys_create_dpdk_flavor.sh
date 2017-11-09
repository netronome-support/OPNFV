#!/bin/bash

. $HOME/adminrc

openstack flavor delete ys_dpdk
openstack flavor create --ram 4096 --disk 8 --vcpus 5 ys_dpdk \
--property hw:cpu_policy=dedicated \
--property hw:cpu_thread_policy=isolate

#nova flavor-key netronome_perf set hw:mem_page_size=2048

openstack flavor list | grep ys_dpdk
