ssh-keygen -f "/home/nic/.ssh/known_hosts" -R 10.30.65.115 && ssh-keygen -f "/home/nic/.ssh/known_hosts" -R $1 && ssh -t $1 sudo yum -y install epel-release && ssh -t $1 sudo yum -y install git python-netifaces python-pip && ssh -t $1 sudo pip install colorama && ssh -t $1 git clone https://github.com/hdb3/openstack-build.git && ssh $1
