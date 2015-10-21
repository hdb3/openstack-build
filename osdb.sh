#!/bin/bash
source config

#create databases
#echo \'Enter the new MySQL root password\'
mysql -u root --password=$DBPASSWORD <<EOF
DROP DATABASE IF EXISTS nova;
DROP DATABASE IF EXISTS cinder;
DROP DATABASE IF EXISTS glance;
DROP DATABASE IF EXISTS keystone;
DROP DATABASE IF EXISTS neutron;
CREATE DATABASE nova;
CREATE DATABASE cinder;
CREATE DATABASE glance;
CREATE DATABASE keystone;
CREATE DATABASE neutron;
GRANT ALL PRIVILEGES ON nova.* TO \'nova\'@\'localhost\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON cinder.* TO \'cinder\'@\'localhost\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON glance.* TO \'glance\'@\'localhost\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON keystone.* TO \'keystone\'@\'localhost\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON neutron.* TO \'neutron\'@\'localhost\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON nova.* TO \'nova\'@\'%\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON cinder.* TO \'cinder\'@\'%\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON glance.* TO \'glance\'@\'%\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON keystone.* TO \'keystone\'@\'%\' IDENTIFIED BY \'$DBPASSWORD\';
GRANT ALL PRIVILEGES ON neutron.* TO \'neutron\'@\'%\' IDENTIFIED BY \'$DBPASSWORD\';
FLUSH PRIVILEGES;
EOF
