#!/bin/bash

ls /home/opnfv/repos/yardstick/tests/opnfv/test_cases/ | xargs -Iz sed -i '/image:/s/^.*$/image: ubuntu16_nfp/' /home/opnfv/repos/yardstick/tests/opnfv/test_cases/z
ls /home/opnfv/repos/yardstick/tests/opnfv/test_cases/ | xargs -Iz sed -i '/flavor:/s/^.*$/flavor: netronome_perf/' /home/opnfv/repos/yardstick/tests/opnfv/test_cases/z
