#!/bin/bash

. $HOME/adminrc

openstack server list --all | awk 'NR>2{print $2}' | xargs -Iz openstack server delete z
