source config

#create users and tenants
export OS_TOKEN=$ADMIN_TOKEN
export OS_URL=http://$CONTROLLER_IP:35357/v2.0

openstack service create --name keystone --description "OpenStack Identity" identity
openstack project create --description "Admin Project" admin
openstack user create --password password admin
openstack role create admin
openstack role add --project admin --user admin admin
openstack project create --description "Service Project" service
# openstack project create --description "Demo Project" demo
# openstack user create --password password demo
# openstack role create user
# openstack role add --project demo --user demo user
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
openstack user create --password $SERVICE_PWD glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image service" image
openstack endpoint create --publicurl http://$CONTROLLER_IP:9292 --internalurl http://$CONTROLLER_IP:9292 --adminurl http://$CONTROLLER_IP:9292 --region RegionOne image
#keystone user-create --name glance --pass $SERVICE_PWD
#keystone user-role-add --user glance --tenant service --role admin
#keystone service-create --name glance --type image --description "OpenStack Image Service"


#install glance

#edit /etc/glance/glance-api.conf
# sed -i.bak -e "/^\[database\]/a \
# connection = mysql://glance:$SERVICE_PWD@$CONTROLLER_IP/glance" /etc/glance/glance-api.conf
crudini --set --verbose /etc/glance/glance-api.conf database connection mysql://glance:$SERVICE_PWD@$CONTROLLER_IP/glance
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken auth_uri http://$CONTROLLER_IP:5000
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken auth_url http://$CONTROLLER_IP:35357
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken auth_plugin password
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken project_domain_id default
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken user_domain_id default
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set --verbose /etc/glance/glance-api.conf keystone_authtoken password $SERVICE_PWD
crudini --set --verbose /etc/glance/glance-api.conf paste_deploy flavor keystone

crudini --set --verbose /etc/glance/glance-api.conf glance_store default_store file
crudini --set --verbose /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

crudini --set --verbose /etc/glance/glance-api.conf DEFAULT notification_driver noop
crudini --set --verbose /etc/glance/glance-api.conf DEFAULT verbose True

#sed -i.bak -e "/^\[keystone_authtoken\]/a \
#auth_uri = http://$CONTROLLER_IP:5000\n\
#auth_url = http://$CONTROLLER_IP:35357\n\
#auth_plugin = password\n\
#project_domain_id = default\n\
#user_domain_id = default\n\
#project_name = service\n\
#username = glance\n\
#password = $SERVICE_PWD" /etc/glance/glance-api.conf

#sed -i.bak -e "/^\[paste_deploy\]/a \
#flavor = keystone" /etc/glance/glance-api.conf

#auth_uri = http://$CONTROLLER_IP:5000/v2.0\n\
#identity_uri = http://$CONTROLLER_IP:35357\n\
#admin_tenant_name = service\n\
#admin_user = glance\n\
#admin_password = $SERVICE_PWD" /etc/glance/glance-api.conf

# sed -i.bak -e "/^\[glance_store\]/a \
# default_store = file\n\
# filesystem_store_datadir = /var/lib/glance/images/" /etc/glance/glance-api.conf

#sed -i.bak -e "/^\[DEFAULT\]/a \
#notification_driver = noop\n\
#verbose = True" /etc/glance/glance-api.conf

#edit /etc/glance/glance-registry.conf
#sed -i.bak -e "/^\[database\]/a \
#connection = mysql://glance:$SERVICE_PWD@$CONTROLLER_IP/glance" /etc/glance/glance-registry.conf

crudini --set --verbose /etc/glance/glance-registry.conf database connection mysql://glance:$SERVICE_PWD@$CONTROLLER_IP/glance
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://$CONTROLLER_IP:5000
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken auth_url http://$CONTROLLER_IP:35357
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken auth_plugin password
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken project_domain_id default
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken user_domain_id default
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken project_name service
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken username glance
crudini --set --verbose /etc/glance/glance-registry.conf keystone_authtoken password $SERVICE_PWD
#sed -i.bak -e "/^\[keystone_authtoken\]/a \
#auth_uri = http://$CONTROLLER_IP:5000\n\
#auth_url = http://$CONTROLLER_IP:35357\n\
#auth_plugin = password\n\
#project_domain_id = default\n\
#user_domain_id = default\n\
#project_name = service\n\
#username = glance\n\
#password = $SERVICE_PWD" /etc/glance/glance-registry.conf
 
crudini --set --verbose /etc/glance/glance-registry.conf paste_deploy flavor keystone
#sed -i.bak -e "/^\[paste_deploy\]/a \
#flavor = keystone" /etc/glance/glance-registry.conf

crudini --set --verbose /etc/glance/glance-registry.conf DEFAULT notification_driver noop
crudini --set --verbose /etc/glance/glance-registry.conf DEFAULT verbose True
#sed -i.bak -e "/^\[DEFAULT\]/a \
#notification_driver = noop\n\
#verbose = True" /etc/glance/glance-registry.conf

#auth_uri = http://$CONTROLLER_IP:5000/v2.0
#identity_uri = http://$CONTROLLER_IP:35357
#admin_tenant_name = service
#admin_user = glance
#admin_password = $SERVICE_PWD" /etc/glance/glance-registry.conf


#start glance
su -s /bin/sh -c "glance-manage db_sync" glance
systemctl enable openstack-glance-api openstack-glance-registry || echo "not needed"
systemctl start openstack-glance-api openstack-glance-registry || echo "not needed"

#upload the cirros image to glance
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
glance image-create --name "cirros-0.3.3-x86_64" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --is-public True --progress
glance image-list
