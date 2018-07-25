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
sudo kubectl cordon k8s-node-1
sudo kubectl scale rc/kube-registry-v0 --replicas=2 -n kube-system


sudo kubectl uncordon k8s-node-1

#sudo docker build -t localhost/spiffe/blog:latest /extra_mount/blog/container_blog
#sudo docker push localhost/spiffe/blog

#sudo docker build -t localhost/spiffe/ghostunnel:latest /extra_mount/blog/container_ghostunnel
#sudo docker push localhost/spiffe/ghostunnel

#sudo kubectl delete -f /extra_mount/blog/blog.yaml || true
#sudo kubectl create -f /extra_mount/blog/blog.yaml

# install and start spire-server
#/extra_mount/install_spire.sh server
#/extra_mount/install_spire.sh agent

# drop user into /opt/spire dir
#echo "cd /opt/spire" >> /home/ubuntu/.bashrc

