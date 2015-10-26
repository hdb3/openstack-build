# openstack-build
 simplified build scripts based on the Centos openstack install scripts from OpenStack documentation
 
 These scripts originate in and target the 'kilo' release, however I expect and intend that later releases should be easily accomodated, hopefully simply by changing the source repository. (see the file 'packages.sh').
 Also, different sources and distros should also be accomodated, e.g. installation from tar balls, or on Ubuntu.
 However, the dependency on systmed (rather than upstart) is intentional and I won't attempt to support upstart (since it is deprecated in Ubuntu since 15.04, and there are workarounds even for 14.04 LTS to use systemd).
 
 Usage
 The file 'do_it' will start a complete installation process.
 The configuration file 'config' is used to provide basic localisation/customisation, e.g. passwords.
 The configuration file 'roles' is used to define a cluster and customise the local installation process for each node - this allows a single configuration to be used across a cluster and thereby ensure consistency between nodes in a cluster.
