#!/bin/bash -ev
source creds
neutron net-create ext-net --router:external --provider:physical_network external --provider:network_type flat
neutron subnet-create --name ext-net --dns-nameserver 8.8.8.8 --enable-dhcp --gateway 10.10.10.1 ext-net 10.10.10.0/24
neutron router-create ext-net
neutron router-interface-add ext-net testnet
neutron router-gateway-set ext-net ext-net
