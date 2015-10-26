
source creds

#create the keystone entries for nova
openstack user create --password $SERVICE_PWD nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create  --publicurl http://$CONTROLLER_IP:8774/v2/%\(tenant_id\)s  --internalurl http://$CONTROLLER_IP:8774/v2/%\(tenant_id\)s  --adminurl http://$CONTROLLER_IP:8774/v2/%\(tenant_id\)s  --region RegionOne  compute

crudini --set --verbose /etc/nova/nova.conf database connection mysql://nova:$DBPASSWD@$CONTROLLER_IP/nova

crudini --set --verbose /etc/nova/nova.conf DEFAULT rpc_backend rabbit
crudini --set --verbose /etc/nova/nova.conf DEFAULT auth_strategy keystone
crudini --set --verbose /etc/nova/nova.conf DEFAULT my_ip $CONTROLLER_IP
crudini --set --verbose /etc/nova/nova.conf DEFAULT vncserver_listen $CONTROLLER_IP
crudini --set --verbose /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address $CONTROLLER_IP
crudini --set --verbose /etc/nova/nova.conf DEFAULT network_api_class nova.network.neutronv2.api.API
crudini --set --verbose /etc/nova/nova.conf DEFAULT security_group_api neutron
crudini --set --verbose /etc/nova/nova.conf DEFAULT linuxnet_interface_driver nova.network.linux_net.LinuxOVSInterfaceDriver
crudini --set --verbose /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver

crudini --set --verbose /etc/nova/nova.conf oslo_messaging_rabbit rabbit_host $CONTROLLER_IP
crudini --set --verbose /etc/nova/nova.conf oslo_messaging_rabbit rabbit_userid openstack
crudini --set --verbose /etc/nova/nova.conf oslo_messaging_rabbit rabbit_password $SERVICE_PWD

crudini --set --verbose /etc/nova/nova.conf keystone_authtoken auth_uri http://$CONTROLLER_IP:5000
crudini --set --verbose /etc/nova/nova.conf keystone_authtoken auth_url http://$CONTROLLER_IP:35357
crudini --set --verbose /etc/nova/nova.conf keystone_authtoken auth_plugin password
crudini --set --verbose /etc/nova/nova.conf keystone_authtoken project_domain_id default
crudini --set --verbose /etc/nova/nova.conf keystone_authtoken user_domain_id default
crudini --set --verbose /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set --verbose /etc/nova/nova.conf keystone_authtoken username nova
crudini --set --verbose /etc/nova/nova.conf keystone_authtoken password $SERVICE_PWD

crudini --set --verbose /etc/nova/nova.conf glance host $CONTROLLER_IP

crudini --set --verbose /etc/nova/nova.conf neutron url http://$CONTROLLER_IP:9696
crudini --set --verbose /etc/nova/nova.conf neutron auth_strategy keystone
crudini --set --verbose /etc/nova/nova.conf neutron admin_auth_url http://$CONTROLLER_IP:35357/v2.0
crudini --set --verbose /etc/nova/nova.conf neutron admin_tenant_name service
crudini --set --verbose /etc/nova/nova.conf neutron admin_username neutron
crudini --set --verbose /etc/nova/nova.conf neutron admin_password $SERVICE_PWD
crudini --set --verbose /etc/nova/nova.conf neutron service_metadata_proxy True
crudini --set --verbose /etc/nova/nova.conf neutron metadata_proxy_shared_secret meta123

su -s /bin/sh -c "nova-manage db sync" nova

systemctl enable openstack-nova-api openstack-nova-cert  openstack-nova-consoleauth openstack-nova-scheduler  openstack-nova-conductor openstack-nova-novncproxy
systemctl start openstack-nova-api openstack-nova-cert  openstack-nova-consoleauth openstack-nova-scheduler  openstack-nova-conductor openstack-nova-novncproxy || echo "not needed"
