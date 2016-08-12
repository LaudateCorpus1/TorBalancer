#!/bin/bash
base_socks_port=19050
base_http_port=31700
base_control_port=38118

# Select fast non-exit Tor nodes for rendezvous points
rpnodes="7489E8EDD0B8B68C8A2CB31D2B56B6572091DA7F,BA75CF7A54E3E2F7DDBB3B05E271C3F8141AB955,5665A3904C89E22E971305EE8C1997BCA4123C69,0EFB58585E50ACBA22EF86AF39F2DEEA217E269D"
rpnodes="$rpnodes,C43FA6474A9F071E9120DF63ED6EB8FDBA105234,D665C959571041972EA8C0DD77559EF5579BA112,18B160CD5E22BFC345AEE7BA84B7EA45BF457FCA,1C90D3AEADFF3BCD079810632C8B85637924A58E"
rpnodes="$rpnodes,6dfeb41c04cce846871338e85dd5acf5cfb6c1dd,3711e80b5b04494c971fb0459d4209ab7f2ea799,b204de75b37064ef6a4c6baf955c5724578d0b32,c804be8fb1c7c42d43c4a5e2039e77aa0ff3a8b4"
rpnodes="$rpnodes,2eb3c230180694a1e848001e20f36f76a2287039,c8200264e43f7920b543f8cdae055e6eecad658e,0266b0660f3f20a7d1f3d8335931c95ef50f6c6b,bcf2ed63ee63e1bcb22a075799da6eeef5ee3feb"
rpnodes="$rpnodes,500fe4d6b529855a2f95a0cb34f2a10d5889e8c1,387b065a38e4daa16d9d41c2964ecbc4b31d30ff,49e7ad01bb96f6fe3ab8c3b15bd2470b150354df,c43fa6474a9f071e9120df63ed6eb8fdba105234"
rpnodes="$rpnodes,1c90d3aeadff3bcd079810632c8b85637924a58e,921da852c95141f8964b359f774b35502e489869"

tor2web_mode=false

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
	if [ "$tor2web_mode" = true ] ; then
		echo "Running: tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword \"\" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i --Tor2webMode 1 --Tor2webRendezvousPoints $rpnodes"
		tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword "" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i --Tor2webMode 1 --Tor2webRendezvousPoints $rpnodes
	fi
	if [ "$tor2web_mode" = false ] ; then
		echo "Running: tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword \"\" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i"
		tor --RunAsDaemon 1 --CookieAuthentication 0 --HashedControlPassword "" --ControlPort $control_port --PidFile tor$i.pid --SocksPort $socks_port --DataDirectory data/tor$i
	fi
	echo "Running: ./delegate/dg*/DGROOT/bin/dg9_9_13 -vs -P$http_port SERVER=http SOCKS=localhost:$socks_port ADMIN='juha.nurmi@ahmia.fi'"
	./delegate/dg*/DGROOT/bin/dg9_9_13 -vs -P$http_port SERVER=http SOCKS=localhost:$socks_port ADMIN="juha.nurmi@ahmia.fi"
done

haproxy -f rotating-tor-proxies.cfg

echo "Delegate processes:"
ps aux | grep delegate | grep dg | wc -l
echo "Tor processes:"
ps aux | grep tor | grep DataDirec | wc -l
