#!/bin/bash

testcase_dir=/home/opnfv/repos/yardstick/tests/opnfv/test_cases

ls $testcase_dir | xargs -Iz sed -i '/image:/s/^.*$/  image: ubuntu16_nfp/' $testcase_dir/z
#ls /home/opnfv/repos/yardstick/tests/opnfv/test_cases/ | xargs -Iz sed -i '/flavor:/s/^.*$/flavor: netronome_perf/' /home/opnfv/repos/yardstick/tests/opnfv/test_cases/z
