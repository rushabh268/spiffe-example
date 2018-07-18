#!/bin/bash

cd /extra_mount/misc_config/
curl --silent --location https://github.com/spiffe/sidecar/releases/download/0.1/sidecar_0.1_linux_amd64.tar.gz | tar xzf -
./sidecar
