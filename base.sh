#!/bin/bash

#get the configuration info
source config

#install keystone

#edit /etc/keystone.conf
sed -i.bak "/^\[DEFAULT\]/a admin_token = ADMIN123" /etc/keystone/keystone.conf
sed -i.bak -e "/^\[database\]/a connection = mysql://keystone:Service123@$CONTROLLER_IP/keystone" /etc/keystone/keystone.conf
sed -i.bak -e "/^\[memcache\]/a servers = localhost:11211\n" /etc/keystone/keystone.conf
sed -i.bak -e "/^\[token\]/a provider = keystone.token.providers.uuid.Provider\ndriver = keystone.token.persistence.backends.memcache.Token" /etc/keystone/keystone.conf
sed -i.bak -e "/^\[revoke\]/a driver = keystone.contrib.revoke.backends.sql.Revoke" /etc/keystone/keystone.conf

#finish keystone setup
#keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
#chown -R keystone:keystone /var/log/keystone
#chown -R keystone:keystone /etc/keystone/ssl
#chmod -R o-rwx /etc/keystone/ssl
su -s /bin/sh -c "keystone-manage db_sync" keystone

sed -i.bak -e "/^ServerRoot/a ServerName $CONTROLLER_IP" /etc/httpd/conf/httpd.conf

mkdir -p /var/www/cgi-bin/keystone

curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin

chown -R keystone:keystone /var/www/cgi-bin/keystone
chmod 755 /var/www/cgi-bin/keystone/*

#start keystone
systemctl enable openstack-keystone
systemctl start openstack-keystone

#schedule token purge
(crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/keystone
  
#create users and tenants
export OS_TOKEN=ADMIN123
export OS_URL=http://$CONTROLLER_IP:35357/v2.0

openstack service create --name keystone --description "OpenStack Identity" identity
openstack project create --description "Admin Project" admin
openstack user create --password password admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --description "Service Project" service
openstack project create --description "Demo Project" demo
openstack user create --password password demo
openstack role create user
openstack role add --project demo --user demo user
openstack endpoint create --publicurl http://$CONTROLLER_IP:5000/v2.0 --internalurl http://$CONTROLLER_IP:5000/v2.0 --adminurl http://$CONTROLLER_IP:35357/v2.0 --region RegionOne identity
#unset OS_TOKEN OS_URL

#openstack role-create --name _member_
#openstack user-role-add --tenant admin --user admin --role _member_
#openstack tenant-create --name demo --description "Demo Tenant"
#openstack user-create --name demo --pass password
#openstack user-role-add --tenant demo --user demo --role _member_
#openstack tenant-create --name service --description "Service Tenant"
#openstack service-create --name keystone --type identity --description "OpenStack Identity"



#create credentials file
echo 'export OS_PROJECT_DOMAIN_ID=default' >> creds
echo 'export OS_USER_DOMAIN_ID=default' >> creds
echo 'export OS_PROJECT_NAME=admin' >> creds
echo 'export OS_TENANT_NAME=admin' >> creds
echo 'export OS_USERNAME=admin' >> creds
echo 'export OS_PASSWORD=password' >> creds
echo 'export OS_AUTH_URL=http://$CONTROLLER_IP:35357/v3' >> creds
source creds

#create keystone entries for glance
openstack user create --password Service123 glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --publicurl http://$CONTROLLER_IP:9292 --internalurl http://$CONTROLLER_IP:9292 --adminurl http://$CONTROLLER_IP:9292 --region RegionOne image
#keystone user-create --name glance --pass Service123
#keystone user-role-add --user glance --tenant service --role admin
#keystone service-create --name glance --type image --description "OpenStack Image Service"


#install glance

#edit /etc/glance/glance-api.conf
sed -i.bak -e "/^\[database\]/a \
connection = mysql://glance:Service123@$CONTROLLER_IP/glance" /etc/glance/glance-api.conf

sed -i.bak -e "/^\[keystone_authtoken\]/a \
auth_uri = http://$CONTROLLER_IP:5000\n\
auth_url = http://$CONTROLLER_IP:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = glance\n\
password = Service123" /etc/glance/glance-api.conf

sed -i.bak -e "/^\[paste_deploy\]/a \
flavor = keystone" /etc/glance/glance-api.conf

#auth_uri = http://$CONTROLLER_IP:5000/v2.0\n\
#identity_uri = http://$CONTROLLER_IP:35357\n\
#admin_tenant_name = service\n\
#admin_user = glance\n\
#admin_password = Service123" /etc/glance/glance-api.conf

sed -i.bak -e "/^\[glance_store\]/a \
default_store = file\n\
filesystem_store_datadir = /var/lib/glance/images/" /etc/glance/glance-api.conf

sed -i.bak -e "/^\[DEFAULT\]/a \
notification_driver = noop\n\
verbose = True" /etc/glance/glance-api.conf

#edit /etc/glance/glance-registry.conf
sed -i.bak -e "/^\[database\]/a \
connection = mysql://glance:Service123@$CONTROLLER_IP/glance" /etc/glance/glance-registry.conf

sed -i.bak -e "/^\[keystone_authtoken\]/a \
auth_uri = http://$CONTROLLER_IP:5000\n\
auth_url = http://$CONTROLLER_IP:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = glance\n\
password = Service123" /etc/glance/glance-registry.conf
 
sed -i.bak -e "/^\[paste_deploy\]/a \
flavor = keystone" /etc/glance/glance-registry.conf

sed -i.bak -e "/^\[DEFAULT\]/a \
notification_driver = noop\n\
verbose = True" /etc/glance/glance-registry.conf

#auth_uri = http://$CONTROLLER_IP:5000/v2.0
#identity_uri = http://$CONTROLLER_IP:35357
#admin_tenant_name = service
#admin_user = glance
#admin_password = Service123" /etc/glance/glance-registry.conf


#start glance
su -s /bin/sh -c "glance-manage db_sync" glance
systemctl enable openstack-glance-api openstack-glance-registry || echo "not needed"
systemctl start openstack-glance-api openstack-glance-registry || echo "not needed"

#upload the cirros image to glance
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
glance image-create --name "cirros-0.3.3-x86_64" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --is-public True --progress
  
#create the keystone entries for nova
openstack user create --password Service123 nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create  --publicurl http://$CONTROLLER_IP:8774/v2/%\(tenant_id\)s  --internalurl http://$CONTROLLER_IP:8774/v2/%\(tenant_id\)s  --adminurl http://$CONTROLLER_IP:8774/v2/%\(tenant_id\)s  --region RegionOne  compute

#install the nova controller components

#edit /etc/nova/nova.conf
sed -i.bak "/^\[database\]/a \
connection = mysql://nova:Service123@$CONTROLLER_IP/nova" /etc/nova/nova.conf

sed -i.bak -e "/^\[DEFAULT\]/a \
rpc_backend = rabbit\n\
auth_strategy = keystone\n\
my_ip = $CONTROLLER_IP\n\
vncserver_listen = $CONTROLLER_IP\n\
vncserver_proxyclient_address = $CONTROLLER_IP\n\
network_api_class = nova.network.neutronv2.api.API\n\
security_group_api = neutron\n\
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver\n\
firewall_driver = nova.virt.firewall.NoopFirewallDriver" /etc/nova/nova.conf

sed -i.bak "/^\[oslo_messaging_rabbit\]/a \
rabbit_host = $CONTROLLER_IP\n\
rabbit_userid = openstack\n\
rabbit_password = Service123" /etc/nova/nova.conf

sed -i.bak -e "/^\[keystone_authtoken\]/a \
auth_uri = http://$CONTROLLER_IP:5000\n\
auth_url = http://$CONTROLLER_IP:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = nova\n\
password = Service123" /etc/nova/nova.conf

sed -i.bak -e "/^\[glance\]/a host = $CONTROLLER_IP" /etc/nova/nova.conf

sed -i.bak -e "/^\[neutron\]/a \
url = http://$CONTROLLER_IP:9696\n\
auth_strategy = keystone\n\
admin_auth_url = http://$CONTROLLER_IP:35357/v2.0\n\
admin_tenant_name = service\n\
admin_username = neutron\n\
admin_password = Service123\n\
service_metadata_proxy = True\n\
metadata_proxy_shared_secret = meta123" /etc/nova/nova.conf

#start nova
su -s /bin/sh -c "nova-manage db sync" nova

systemctl enable openstack-nova-api openstack-nova-cert  openstack-nova-consoleauth openstack-nova-scheduler  openstack-nova-conductor openstack-nova-novncproxy
systemctl start openstack-nova-api openstack-nova-cert  openstack-nova-consoleauth openstack-nova-scheduler  openstack-nova-conductor openstack-nova-novncproxy || echo "not needed"

#create keystone entries for neutron
openstack user create --password Service123 neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create  --publicurl http://$CONTROLLER_IP:9696  --internalurl http://$CONTROLLER_IP:9696  --adminurl http://$CONTROLLER_IP:9696  --region RegionOne  network
source config
#install neutron

#edit /etc/neutron/neutron.conf
sed -i.bak "/\[database\]/a \
connection = mysql://neutron:Service123@$CONTROLLER_IP/neutron" /etc/neutron/neutron.conf

SERVICE_TENANT_ID=$(keystone tenant-list | awk '/ service / {print $2}')

sed -i -e "/^\[DEFAULT\]/a \
rpc_backend = rabbit\n\
auth_strategy = keystone\n\
core_plugin = ml2\n\
service_plugins = router\n\
allow_overlapping_ips = True\n\
notify_nova_on_port_status_changes = True\n\
notify_nova_on_port_data_changes = True\n\
nova_url =  http://$CONTROLLER_IP:8774/v2" /etc/neutron/neutron.conf

sed -i -e "/^\[oslo_messaging_rabbit\]/a \
rabbit_host = $CONTROLLER_IP\n\
rabbit_userid = openstack\n\
rabbit_password = Service123" /etc/neutron/neutron.conf

sed -i -e "/^\[nova\]/a \
auth_url =  http://$CONTROLLER_IP:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
region_name = RegionOne\n\
project_name = service\n\
username = nova\n\
password =Service123" /etc/neutron/neutron.conf


sed -i -e "/^\[keystone_authtoken\]/a \
auth_uri = http://$CONTROLLER_IP:5000\n\
auth_url = http://$CONTROLLER_IP:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = neutron\n\
password = Service123" /etc/neutron/neutron.conf

#edit /etc/neutron/plugins/ml2/ml2_conf.ini
sed -i -e "/^\[ml2\]/a \
type_drivers = flat,vlan,gre,vxlan\n\
tenant_network_types = gre\n\
mechanism_drivers = openvswitch" /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i -e "/^\[ml2_type_gre\]/a \
tunnel_id_ranges = 1:1000" /etc/neutron/plugins/ml2/ml2_conf.ini

sed -i -e "/^\[securitygroup\]/a \
enable_security_group = True\n\
enable_ipset = True\n\
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/ml2_conf.ini

#start neutron
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
systemctl restart openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service
systemctl enable neutron-server.service
systemctl start neutron-server.service
source config
#install cinder controller

#cp /usr/share/cinder/cinder-dist.conf /etc/cinder/cinder.conf
chown -R cinder:cinder /etc/cinder/cinder.conf

#edit /etc/cinder/cinder.conf
sed -i.bak "/\[database\]/a connection = mysql://cinder:Service123@$CONTROLLER_IP/cinder" /etc/cinder/cinder.conf

sed -i "/^\[DEFAULT\]/a \
rpc_backend = rabbit\n\
my_ip = $CONTROLLER_IP\n\
auth_strategy = keystone" /etc/cinder/cinder.conf

sed -i "/^\[oslo_messaging_rabbit\]/a \
rabbit_host = $CONTROLLER_IP\n\
rabbit_userid = openstack\n\
rabbit_password =Service123" /etc/cinder/cinder.conf

sed -i "/^\[oslo_concurrency\]/a \
lock_path = /var/lock/cinder" /etc/cinder/cinder.conf

sed -i "/^\[keystone_authtoken\]/a \
auth_uri = http://$CONTROLLER_IP:5000\n\
auth_url = http://$CONTROLLER_IP:35357\n\
auth_plugin = password\n\
project_domain_id = default\n\
user_domain_id = default\n\
project_name = service\n\
username = cinder\n\
password = Service123" /etc/cinder/cinder.conf

#start cinder controller
su -s /bin/sh -c "cinder-manage db sync" cinder
systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service
