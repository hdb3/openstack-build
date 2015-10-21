#!/bin/bash
source config
systemctl enable ntpd || echo "not needed"
systemctl start ntpd || echo "not needed"
systemctl stop firewalld || echo "not needed"
systemctl disable firewalld || echo "not needed"

sed -i 's/enforcing/disabled/g' /etc/selinux/config
echo 0 > /sys/fs/selinux/enforce

#install messaging service
systemctl enable rabbitmq-server || echo "not needed"
systemctl start rabbitmq-server || echo "not needed"

rabbitmqctl add_user openstack Service123 || echo "not needed"
rabbitmqctl set_permissions openstack ".*" ".*" ".*"


systemctl enable memcached || echo "not needed"
systemctl start memcached || echo "not needed"

systemctl enable httpd || echo "not needed"
systemctl start httpd || echo "not needed"

#edit /etc/my.cnf
sed -i.bak "10i\\
bind-address = $CONTROLLER_IP\n\
default-storage-engine = innodb\n\
innodb_file_per_table\n\
collation-server = utf8_general_ci\n\
init-connect = 'SET NAMES utf8'\n\
character-set-server = utf8\n\
max_connections = 25000" /etc/my.cnf

#start database server
systemctl enable mariadb || echo "not needed"
systemctl start mariadb || echo "not needed"

#echo 'now run through the mysql_secure_installation'
mysql_secure_installation
