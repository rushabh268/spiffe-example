#!/bin/bash

set -x

set_hostname() {
	sudo hostname $1
	echo "127.0.0.1 $1" | sudo tee -a /etc/hosts >/dev/null
	echo "$1" | sudo tee  /etc/hostname >/dev/null
}

set_hostname blog

sudo apt-get update
sudo apt-get -y install python-pip python-mysqldb git

cd /home/ubuntu

git clone https://github.com/sh4nks/flaskbb.git
cd flaskbb
sudo pip install -r requirements.txt

cp /tmp/remote/flaskbb.cfg .

/tmp/remote/install_spire.sh agent
/tmp/remote/install_sidecar.sh
/tmp/remote/install_envoy.sh

sudo cp /tmp/remote/hot-restarter.py /opt/sidecar/bin/
sudo cp /tmp/remote/start_envoy.sh /opt/sidecar/bin/
sudo cp /tmp/remote/sidecar_config.hcl /opt/sidecar/bin/
sudo cp /tmp/remote/blog_envoy.json /opt/sidecar/bin/envoy.json
