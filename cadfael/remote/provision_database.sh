#!/bin/bash

set -x

apt_get_wrapper() {
	DEBIAN_FRONTEND=noninteractive sudo -E apt-get \
		--yes --force-yes -qq \
		--no-install-suggests \
		--no-install-recommends \
		-o Dpkg::Options::="--force-confdef" \
		-o Dpkg::Options::="--force-confnew" \
		"$@"
}

set_hostname() {
	sudo hostname $1
	echo "127.0.0.1 $1" | sudo tee -a /etc/hosts >/dev/null
	echo "$1" | sudo tee  /etc/hostname >/dev/null
}

set_hostname database

apt_get_wrapper update
apt_get_wrapper install mariadb-server
apt_get_wrapper install python-pip

# wipe any exsting DB config
cat <<_EOF | sudo mysql || true
drop user 'dbuser'@'%';
drop database forum_db;
_EOF

cat <<_EOF | sudo mysql
create user 'dbuser'@'%' identified by 'badpass';
grant all on *.* to 'dbuser'@'%';
flush privileges;
create database forum_db;
_EOF

# restore our static forum_db dump
cat /tmp/remote/forum_db.dump | sudo mysql forum_db

/tmp/remote/install_spire.sh agent
/tmp/remote/install_envoy.sh
/tmp/remote/install_sidecar.sh


sudo cp /tmp/remote/hot-restarter.py /opt/sidecar/bin/
sudo cp /tmp/remote/start_envoy.sh /opt/sidecar/bin/
sudo cp /tmp/remote/sidecar_config.hcl /opt/sidecar/bin/
sudo cp /tmp/remote/database_envoy.json /opt/sidecar/bin/envoy.json
