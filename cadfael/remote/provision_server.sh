#!/bin/bash

set -x

set_hostname() {
	sudo hostname $1
	echo "127.0.0.1 $1" | sudo tee -a /etc/hosts >/dev/null
	echo "$1" | sudo tee  /etc/hostname >/dev/null
}

set_hostname server

/tmp/remote/install_spire.sh server

