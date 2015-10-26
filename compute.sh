echo 'net.ipv4.conf.all.rp_filter=0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter=0' >> /etc/sysctl.conf
# echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
# echo 'net.bridge.bridge-nf-call-ip6tables=1' >> /etc/sysctl.conf
sysctl -p
yum -y install openstack-nova-compute sysfsutils openstack-neutron openstack-neutron-ml2 openstack-neutron-openvswitch
crudini --set --verbose /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
COMPUTE_SERVICES="openvswitch libvirtd openstack-nova-compute neutron-openvswitch-agent"

systemctl enable $COMPUTE_SERVICES
systemctl start $COMPUTE_SERVICES
