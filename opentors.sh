#!/bin/bash
base_socks_port=9050
base_http_port=31700
base_control_port=38118

# Select fast non-exit Tor nodes for rendezvous points
rpnodes="7489E8EDD0B8B68C8A2CB31D2B56B6572091DA7F BA75CF7A54E3E2F7DDBB3B05E271C3F8141AB955 5665A3904C89E22E971305EE8C1997BCA4123C69 0EFB58585E50ACBA22EF86AF39F2DEEA217E269D"
rpnodes="$rpnodes C43FA6474A9F071E9120DF63ED6EB8FDBA105234 D665C959571041972EA8C0DD77559EF5579BA112 18B160CD5E22BFC345AEE7BA84B7EA45BF457FCA 1C90D3AEADFF3BCD079810632C8B85637924A58E"

# Create data directory if it doesn't exist
if [ ! -d "data" ]; then
	mkdir "data"
fi

for i in {0..9}
do
	socks_port=$((base_socks_port+i))
	control_port=$((base_control_port+i))
	http_port=$((base_http_port+i))
	if [ ! -d "data/tor$i" ]; then
		echo "Creating directory data/tor$i"
		mkdir "data/tor$i"
	fi
	# Take into account that authentication for the control port is disabled. Must be used in secure and controlled environments
	echo "Running: tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword \"\" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i --Tor2webRendezvousPoints $rpnodes"
	tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword "" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i --Tor2webRendezvousPoints $rpnodes
	echo "Running: ./delegate/dg*/DGROOT/bin/dg9_9_13 -vs -P$http_port SERVER=http SOCKS=localhost:$socks_port ADMIN='juha.nurmi@ahmia.fi'"
	./delegate/dg*/DGROOT/bin/dg9_9_13 -vs -P$http_port SERVER=http SOCKS=localhost:$socks_port ADMIN="juha.nurmi@ahmia.fi"
done

haproxy -f rotating-tor-proxies.cfg

echo "Delegate processes:"
ps aux | grep delegate | grep dg | wc -l
echo "Tor processes:"
ps aux | grep tor | grep DataDirec | wc -l
