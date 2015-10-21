
source config

yum -y reinstall openstack-keystone
sed -i -e "/^#/d" /etc/keystone/keystone.conf
sed -i -e "/^$/d" /etc/keystone/keystone.conf

crudini --set --verbose /etc/keystone/keystone.conf DEFAULT admin_token $ADMIN_TOKEN
crudini --set --verbose /etc/keystone/keystone.conf database connection "mysql://keystone:$DBPASSWD@$CONTROLLER_IP/keystone"
crudini --set --verbose /etc/keystone/keystone.conf memcache servers localhost:11211
crudini --set --verbose /etc/keystone/keystone.conf token provider keystone.token.providers.uuid.Provider
crudini --set --verbose /etc/keystone/keystone.conf token driver keystone.token.persistence.backends.memcache.Token
crudini --set --verbose /etc/keystone/keystone.conf revoke driver keystone.contrib.revoke.backends.sql.Revoke
#exit
#keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
#chown -R keystone:keystone /var/log/keystone
#chown -R keystone:keystone /etc/keystone/ssl
#chmod -R o-rwx /etc/keystone/ssl
su -s /bin/sh -c "keystone-manage db_sync" keystone || echo "*** keystone-manage db_sync FAILED"

sed -i.bak -e "/^ServerRoot/a ServerName $CONTROLLER_IP" /etc/httpd/conf/httpd.conf

mkdir -p /var/www/cgi-bin/keystone

curl http://git.openstack.org/cgit/openstack/keystone/plain/httpd/keystone.py?h=stable/kilo | tee /var/www/cgi-bin/keystone/main /var/www/cgi-bin/keystone/admin

chown -R keystone:keystone /var/www/cgi-bin/keystone
chmod 755 /var/www/cgi-bin/keystone/*

systemctl enable openstack-keystone
systemctl start openstack-keystone
