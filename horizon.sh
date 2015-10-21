source config
#install dashboard

#edit /etc/openstack-dashboard/local_settings
sed -i.bak -e "s/ALLOWED_HOSTS = \['horizon.example.com', 'localhost'\]/ALLOWED_HOSTS = '*'/" /etc/openstack-dashboard/local_settings
sed -i -e 's/OPENSTACK_HOST = "127.0.0.1"/OPENSTACK_HOST = "'"$CONTROLLER_IP"'"/' /etc/openstack-dashboard/local_settings

sed -i "s/CACHES = {\n    'default': {\n        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',\n        'LOCATION': '127.0.0.1:11211',\n    }\n\}/" /etc/openstack-dashboard/local_settings

sed -i 's/OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"/' /etc/openstack-dashboard/local_settings



#start dashboard
setsebool -P httpd_can_network_connect on
chown -R apache:apache /usr/share/openstack-dashboard/static
systemctl enable httpd.service memcached.service
systemctl start httpd.service memcached.service

#create keystone entries for cinder
openstack user create --password Service123 cinder
openstack role add --project service --user cinder admin
openstack service create --name cinder --description "OpenStack Block Storage" volume
openstack service create --name cinderv2 --description "OpenStack Block Storage" volume2
openstack endpoint create --publicurl http://$CONTROLLER_IP:8776/v2/%\(tenant_id\)s --internalurl http://$CONTROLLER_IP:8776/v2/%\(tenant_id\)s --adminurl http://$CONTROLLER_IP:8776/v2/%\(tenant_id\)s --region RegionOne volume
openstack endpoint create --publicurl http://$CONTROLLER_IP:8776/v2/%\(tenant_id\)s --internalurl http://$CONTROLLER_IP:8776/v2/%\(tenant_id\)s --adminurl http://$CONTROLLER_IP:8776/v2/%\(tenant_id\)s --region RegionOne volume2

