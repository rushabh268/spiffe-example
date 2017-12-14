#!/bin/bash

set -x

ENVOY_GZ="https://s3.us-east-2.amazonaws.com/scytale-artifacts/envoy-448a4a5.gz"

sudo rm -rf /opt/envoy
sudo mkdir -p /opt/envoy/bin

curl --silent --location --output /tmp/envoy.gz $ENVOY_GZ
gunzip -f /tmp/envoy.gz
chmod a+rx /tmp/envoy
sudo mv /tmp/envoy /opt/envoy/bin/
