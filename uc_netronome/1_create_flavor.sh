#!/bin/bash

. $HOME/adminrc

openstack flavor create --ram 4096 --disk 8 --vcpus 4 netronome_perf --property hw_cpu_policy=dedicated \
--property hw_cpu_thread_policy=isolate

nova flavor-key netronome_perf set hw:mem_page_size=2048

openstack flavor list | grep netronome_perf
