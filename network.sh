echo 'net.ipv4.conf.all.rp_filter=0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter=0' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf
sysctl -p
# crudini --set --verbose 
NETWORK-SERVICES="openvswitch libvirtd openstack-nova-compute neutron-openvswitch-agent"

systemctl enable NETWORK-SERVICES
systemctl start NETWORK-SERVICES
