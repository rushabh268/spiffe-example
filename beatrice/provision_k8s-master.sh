#!/bin/bash

set -x
sudo kubectl apply --filename=/vagrant/flannel.yaml
sudo kubectl apply --filename=/vagrant/registry.yaml

#sudo kubectl apply --filename=/extra_mount/registry.yaml
# wait for registry to become available
#while ! curl --silent --fail --output /dev/null localhost; do
#	sleep 1
#done

sleep 100

sudo docker build -t localhost/spiffe/blog:latest /extra_mount/blog/container_blog
sudo docker push localhost/spiffe/blog

sudo docker build -t localhost/spiffe/ghostunnel:latest /extra_mount/blog/container_ghostunnel
sudo docker push localhost/spiffe/ghostunnel

sudo docker save --output ghostunnel.tar localhost/spiffe/ghostunnel:latest
sudo docker save --output blog.tar localhost/spiffe/blog 
sudo chown vagrant:vagrant /home/vagrant/*

# install and start spire-server
/extra_mount/install_spire.sh server
/extra_mount/install_spire.sh agent

