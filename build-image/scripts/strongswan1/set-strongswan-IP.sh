ifconfig eth1 10.250.11.3 netmask 255.255.255.0
ifconfig eth2 10.250.13.3 netmask 255.255.255.0

ip route add 10.250.12.0/24 via 10.250.13.4 dev eth2
arp -i eth1 -s 10.250.11.2 2a:7f:cb:e0:37:3e
