#!/bin/bash

set -x

#Install the spire agent
/extra_mount/install_spire.sh agent

# drop user into /opt/spire dir
#echo "cd /opt/spire" >> /home/ubuntu/.bashrc

