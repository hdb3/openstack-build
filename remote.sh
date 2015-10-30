#!/bin/bash -e
for node in "$@"
do
    echo "$node"
    ssh-keygen -f "/home/nic/.ssh/known_hosts" -R `dig +short $node`
    ssh-keygen -f "/home/nic/.ssh/known_hosts" -R $node
    scp *sh config roles do_it subnet.py role.py $node:
    ssh -t $node ./do_it
done
