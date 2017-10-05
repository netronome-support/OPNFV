#!/bin/bash
script_dir="$(dirname $(readlink -f $0))"
/$script_dir/create_image/CREATE_OPNFV_IMAGE.sh
