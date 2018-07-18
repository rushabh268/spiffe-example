#!/bin/bash

set -x

## complicated build of ghostunnel branch on a fork

GOLANG_URL=https://storage.googleapis.com/golang/go1.9.1.linux-amd64.tar.gz
GHOSTUNNEL_BRANCH=spiffe-support

sudo apt-get -y install build-essential libltdl-dev git

#export PATH=/usr/local/go/bin:/home/vagrant/go/bin:$PATH
# ghostunnel requires golang1.9, so we fetch a tarball

curl --silent $GOLANG_URL | sudo tar --directory /usr/local -xzf -

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
sudo rm -rf /home/vagrant/go
sudo mkdir -p /home/vagrant/go/src/github.com/spiffe
cd /home/vagrant/go/src/github.com/spiffe
go get ./.
#cd src/github.com/spiffe
sudo git clone --branch $GHOSTUNNEL_BRANCH  https://github.com/spiffe/ghostunnel.git
cd ghostunnel
go install

# send a copy to our container friend
sudo cp -r /home/vagrant/go/src/github.com/spiffe/ghostunnel /extra_mount/blog/container_ghostunnel/

# abusing .bash_aliases to ammend PATH, for convenience
#sudo echo "export PATH=/usr/local/go/bin:/home/ubuntu/go/bin:$PATH" > /home/ubuntu/.bash_aliases

