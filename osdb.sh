#!/bin/bash
source config

echo "the password is $DBPASSWD"
#create databases
mysql -u root --password=$DBPASSWD <<EOF
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
EOF
mysql -u root --password=$DBPASSWD -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$DBPASSWD';"
# GRANT ALL PRIVILEGES ON cinder.* TO "cinder"@"localhost" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON glance.* TO "glance"@"localhost" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON keystone.* TO "keystone"@"localhost" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON neutron.* TO "neutron"@"localhost" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON nova.* TO "nova"@"%" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON cinder.* TO "cinder"@"%" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON glance.* TO "glance"@"%" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON keystone.* TO "keystone"@"%" IDENTIFIED BY "$DBPASSWD";
# GRANT ALL PRIVILEGES ON neutron.* TO "neutron"@"%" IDENTIFIED BY "$DBPASSWD";
mysql -u root --password=$DBPASSWD -e "FLUSH PRIVILEGES;"
