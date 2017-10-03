#!/bin/bash

apt-get update

apt-get -y install make cmake gcc libpcap-dev python unzip python-scapy python-pip cloud-init

pip install numpy
pip install plotly
