#!/bin/bash -e
ssh-keygen -f "/home/nic/.ssh/known_hosts" -R `dig +short $1`
ssh-keygen -f "/home/nic/.ssh/known_hosts" -R $1
scp *sh config roles do_it subnet.py role.py $1:
ssh -t $1 ./do_it
