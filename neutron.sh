
crudini --set --verbose  /etc/neutron/neutron.conf database connection mysql://neutron:$DBPASSWD@$CONTROLLER_IP/neutron

# SERVICE_TENANT_ID=$(keystone tenant-list | awk '/ service / {print $2}')

crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT rpc_backend rabbit
crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT core_plugin ml2
crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT service_plugins router
crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips True
crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes True
crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes True
crudini --set --verbose  /etc/neutron/neutron.conf DEFAULT nova_url  http://$CONTROLLER_IP:8774/v2

crudini --set --verbose  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_host $CONTROLLER_IP
crudini --set --verbose  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set --verbose  /etc/neutron/neutron.conf oslo_messaging_rabbit rabbit_password $SERVICE_PWD

crudini --set --verbose  /etc/neutron/neutron.conf nova auth_url  http://$CONTROLLER_IP:35357
crudini --set --verbose  /etc/neutron/neutron.conf nova auth_plugin password
crudini --set --verbose  /etc/neutron/neutron.conf nova project_domain_id default
crudini --set --verbose  /etc/neutron/neutron.conf nova user_domain_id default
crudini --set --verbose  /etc/neutron/neutron.conf nova region_name RegionOne
crudini --set --verbose  /etc/neutron/neutron.conf nova project_name service
crudini --set --verbose  /etc/neutron/neutron.conf nova username nova
crudini --set --verbose  /etc/neutron/neutron.conf nova password $SERVICE_PWD

crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken auth_uri http://$CONTROLLER_IP:5000
crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken auth_url http://$CONTROLLER_IP:35357
crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken auth_plugin password
crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken project_domain_id default
crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken user_domain_id default
crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken project_name service
crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken username neutron
crudini --set --verbose  /etc/neutron/neutron.conf keystone_authtoken password $SERVICE_PWD

crudini --set --verbose  /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan,gre,vxlan
crudini --set --verbose  /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types gre
crudini --set --verbose  /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers openvswitch

crudini --set --verbose  /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_gre tunnel_id_ranges 1:1000

crudini --set --verbose  /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_security_group True
crudini --set --verbose  /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset True
crudini --set --verbose  /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
if [[ $MY_ROLE == "controller" ]] ; then
  echo "running controller node setup"
  source creds
  openstack user create --password $SERVICE_PWD neutron
  openstack role add --project service --user neutron admin
  openstack service create --name neutron --description "OpenStack Networking" network
  openstack endpoint create  --publicurl http://$CONTROLLER_IP:9696  --internalurl http://$CONTROLLER_IP:9696  --adminurl http://$CONTROLLER_IP:9696  --region RegionOne  network
  su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
  systemctl restart openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service
  systemctl enable neutron-server.service
  systemctl start neutron-server.service
