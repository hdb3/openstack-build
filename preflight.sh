#!/bin/bash
systemctl enable ntpd || echo "not needed"
systemctl start ntpd || echo "not needed"
systemctl stop firewalld || echo "not needed"
systemctl disable firewalld || echo "not needed"

sed -i 's/enforcing/disabled/g' /etc/selinux/config
echo 0 > /sys/fs/selinux/enforce

if [[ $MY_ROLE =~ "controller" ]] ; then
  echo "running controller node setup"
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

sed -i -e "/^\!includedir/d" /etc/my.cnf
sed -i -e "/^#/d" /etc/my.cnf
echo "CONTROLLER_IP=$CONTROLLER_IP"
crudini --set --verbose /etc/my.cnf mysqld bind-address $CONTROLLER_IP
crudini --set --verbose /etc/my.cnf mysqld default-storage-engine innodb
crudini --set --verbose /etc/my.cnf mysqld innodb_file_per_table
crudini --set --verbose /etc/my.cnf mysqld collation-server utf8_general_ci
crudini --set --verbose /etc/my.cnf mysqld init-connect "'SET NAMES utf8'"
crudini --set --verbose /etc/my.cnf mysqld character-set-server utf8
crudini --set --verbose /etc/my.cnf mysqld max_connections 25000
#start database server
#wipe the database directory in case this is not the first attempt to install openstack
systemctl stop mariadb || echo "mariadb not running yet...."
rm -rf /var/lib/mysql/*
systemctl enable mariadb || echo "not needed"
systemctl start mariadb || echo "not needed"
mysqladmin -u root password $DBPASSWD
fi 
