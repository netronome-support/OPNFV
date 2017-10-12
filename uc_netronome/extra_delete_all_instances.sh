#!/bin/bash

. $HOME/adminrc

openstack port list | awk '/demo/{print $2}' | xargs -Iz openstack port delete z
