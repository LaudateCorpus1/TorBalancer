# TorBalancer

Balance traffic between multiple Tor clients.

Keeps the circuit and returns connections according to onion address.

```
HAProxy <--HTTP-->  DeleGate1 <--socks--> Tor1  <-->  Rendezvous Points
                    DeleGate2 <--socks--> Tor2  <-->  Rendezvous Points
                    ...
                    DeleGate9 <--socks--> Tor9  <-->  Rendezvous Points
```

![Stats GUI](https://github.com/ahmia/TorBalancer/blob/master/stats.png)


## Setup TorBalancer

```sh
sudo ./install.sh
```

## Start the system

```sh
$ bash opentors.sh
```

## Finally, you can test your HAProxy:

```sh
$ curl -x localhost:3128 http://msydqstlz2kzerdg.onion/
$ http://localhost:5000/stats
```

## Shutdown

You can kill your Tors, DeleGates and HAProxy by

```sh
$ killall haproxy
$ killall tor
$ kill $(ps aux | grep 'delegate' | awk '{print $2}')
```

## Old way to setup with one Polipo proxy

- Tor + Polipo
- No load balancing
- One Tor + proxy instance

```sh
$ sudo apt-get install polipo
$ sudo cp polipo_conf /etc/polipo/config
$ sudo service polipo restart
```
