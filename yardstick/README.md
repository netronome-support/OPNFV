# OPNFV - performance setup scripts

> **NOTE** Perform the following steps on the Jump Host

## Determine undercloud IP

virsh domifaddr undercloud
undercloud_ip=`virsh domifaddr undercloud|awk 'NR==3{print $4}'| cut -d '/' -f1`

## Prepare rc file

* Grab undercloudrc.v3 from undercloud

```
scp $undercloud_ip:/home/stack/overcloudrc.v3 /root/
```

* Specify network

```
export EXTERNAL_NETWORK=external
```

* cat 

```
export EXTERNAL_NETWORK=external
```


## Pull docker container

docker pull opnfv/yardstick:stable

docker images

## Boot container

undercloud_ip=192.168.122.169
docker run -itd --privileged -v /home/cloud/overcloudrc/openstack.creds:/etc/yardstick/openstack.creds \
-v /root/.ssh/id_rsa:/etc/yardstick/id_rsa \
-v /var/run/docker.sock:/var/run/docker.sock \
-p 8888:5000 -e "INSTALLER_IP=$undercloud_ip" \
-e "INSTALLER_TYPE=apex" -e "NODE_NAME=OCP" \
-e "DEPLOY_SCENARIO=os-nosdn-nofeature-ha" \
--name "yardstick_container_name" opnfv/yardstick:stable

## Enter container

docker ps
docker exec -it yardstick_ocp /bin/bash

## Configure dispatcher

cp /home/opnfv/repos/yardstick/etc/yardstick/yardstick.conf.sample /etc/yardstick/yardstick.conf


## Configure influxDB from within container

yardstick env influxdb


## Configure grafana from Jump Host

yardstick env grafana





