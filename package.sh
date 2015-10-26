
yum -y install yum-plugin-priorities
yum -y install epel-release
yum -y install http://rdo.fedorapeople.org/openstack-kilo/rdo-release-kilo.rpm
yum -y upgrade
yum -y install openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient wget openstack-glance python-glance python-glanceclient openstack-keystone httpd mod_wsgi python-openstackclient memcached python-memcached rabbitmq-server mariadb mariadb-server MySQL-python ntp openstack-neutron openstack-neutron-ml2 python-neutronclient openstack-dashboard httpd mod_wsgi memcached python-memcached openstack-cinder python-cinderclient python-oslo-db
