# openstack-build
 simplified build scripts based on the Centos openstack install scripts from OpenStack documentation
 
 These scripts originate in and target the 'kilo' release, however I expect and intend that later releases should be easily accomodated, hopefully simply by changing the source repository. (see the file 'packages.sh').
 Also, different sources and distros should also be accomodated, e.g. installation from tar balls, or on Ubuntu.
 However, the dependency on systemd (rather than upstart) is intentional and I won't attempt to support upstart (since it is deprecated in Ubuntu since 15.04, and there are workarounds even for 14.04 LTS to use systemd).

## Usage
 The file 'do_it' will start a complete installation process.
 The configuration file 'config' is used to provide basic localisation/customisation, e.g. passwords.
 The configuration file 'roles' is used to define a cluster and customise the local installation process for each node - this allows a single configuration to be used across a cluster and thereby ensure consistency between nodes in a cluster.
## Quick Explanation
There are three phases in the installation process
* installation (currently form the distro packages for yum/centos)
* pre-flight - install/configure infrastructure services like mysql, Rabbit MQ (server and/or client libraries)
* OpenStack configuration and installation
 * this phase is broken over several script files
 * on a controller node it is quite complex, and includes the project specific keystone and mysql database setup
 * the project specific configurartion (other than keystone and mysql) is done in script files named by project (nova.sh, neutron.sh,...)
 * NOTE: the project specific scripts run _before_ the database initialisation, because on the controller project specific database initialisation use the configuration to customisation the databases.
## Quick start
 * You can populate bare Centos nodes with the required bootstrap files to run these scripts by using the script remote.sh:  run 'remote.sh <node name or ip address>', after editing the 'roles' file to reflect your actual configuration.
