#!/bin/bash

. $HOME/adminrc

openstack flavor delete netronome_perf_dedicated
openstack flavor create --ram 4096 --disk 8 --vcpus 6 netronome_perf_dedicated \
--property hw:cpu_policy=dedicated \
--property hw:cpu_thread_policy=isolate

openstack flavor list | grep netronome_perf
