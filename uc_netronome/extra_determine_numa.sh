#!/bin/bash

echo NUMA
echo

for card in /sys/bus/pci/drivers/nfp/0*; do
    address=`basename $card`
    echo "Agilio address: $address"
    echo -n "NUMA node: "; cat $card/numa_node
    echo -n "Local CPUs: "; cat $card/local_cpulist
done

echo
echo HUGEPAGES
echo
cat /proc/meminfo | grep -i huge
