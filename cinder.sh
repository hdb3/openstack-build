source config
source creds
#install cinder controller

#cp /usr/share/cinder/cinder-dist.conf /etc/cinder/cinder.conf
chown -R cinder:cinder /etc/cinder/cinder.conf

#edit /etc/cinder/cinder.conf
sed -i.bak "/\[database\]/a connection = mysql://cinder:$SERVICE_PASSWD@$CONTROLLER_IP/cinder" /etc/cinder/cinder.conf

sed -i "/^\[DEFAULT\]/a \
rpc_backend = rabbit\n\
my_ip = $CONTROLLER_IP\n\
auth_strategy = keystone" /etc/cinder/cinder.conf

sed -i "/^\[oslo_messaging_rabbit\]/a \
rabbit_host = $CONTROLLER_IP\n\
rabbit_userid = openstack\n\
rabbit_password =$SERVICE_PASSWD" /etc/cinder/cinder.conf

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
password = $SERVICE_PASSWD" /etc/cinder/cinder.conf

#start cinder controller
su -s /bin/sh -c "cinder-manage db sync" cinder
systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service
systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service
