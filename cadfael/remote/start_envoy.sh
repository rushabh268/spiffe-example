#!/bin/bash

exec /opt/envoy/bin/envoy -c ./envoy.json --restart-epoch $RESTART_EPOCH -l off
