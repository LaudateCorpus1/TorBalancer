#!/bin/bash

set -euf -o pipefail

release=`lsb_release -cs`

setup_haproxy() {
	if which haproxy > /dev/null; then
		echo "Skipping HAProxy because you have it installed"
		return
	fi
	echo "Setting up HAProxy"
	apt-get -yqq install haproxy
	service haproxy stop
	update-rc.d -f haproxy remove
	ulimit -n 65536
}

setup_polipo() {
	if which polipo > /dev/null; then
		echo "Skipping Polipo because you have it installed"
		return
	fi
	echo "Setting up Polipo"
	apt-get -yqq install polipo
}

setup_tor() {
	if which tor > /dev/null; then
		echo "Skipping Tor because you have it installed"
		return
	fi
	echo "Setting up Tor"
	echo "deb http://deb.torproject.org/torproject.org $release main
	deb-src http://deb.torproject.org/torproject.org $release main" > /etc/apt/sources.list.d/tor.list
	gpg --keyserver keys.gnupg.net --recv 886DDD89
	gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

	apt-get update -qq

	apt-get install -yqq tor deb.torproject.org-keyring
	service tor stop
	update-rc.d -f tor remove

	# # Get the Source
	# mkdir -p ~/tor2web-buildenv/debian-packages
	# cd ~/tor2web-buildenv/debian-packages

	# apt-get update -qq
	# apt-get install -yqq deb.torproject.org-keyring
	# apt-get update -qq
	# apt-get install -yqq fakeroot devscripts
	# apt-get build-dep -yqq tor
	# apt-get source tor
	# cd tor-*

	# # Patching for Tor2Web updates
	# cat debian/rules | sed 's/--enable-gcc-warnings-advisory/--enable-gcc-warnings-advisory \
	#         --enable-tor2web-mode/' > debian/rules
	# wget -O patch_hs.patch 'https://raw.githubusercontent.com/globaleaks/Tor2web/397c8cea8afb3daa3a041626fc4ee46e4d07345d/contrib/torpatch'
	# patch -p1 < patch_hs.patch
	# debuild -rfakeroot -uc -us
	# cd ..
	# dpkg -i tor*.deb
	# sudo apt-mark hold tor tor-dbg tor-geoipdb

}

echo "Start setting up your TorBalancer!"
setup_haproxy
setup_polipo
setup_tor
echo "All done setting up your TorBalancer!"
