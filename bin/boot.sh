#! /bin/bash

set -e

IP_ADDRESS=$(ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

sed -i.bak "s/127.0.0.1/$IP_ADDRESS/" /etc/riak/vm.args
service riak start
riak-admin wait-for-service riak_kv riak@$IP_ADDRESS

if env | grep -q SEED_PORT_22_TCP_ADDR
then
  riak-admin cluster join riak@$SEED_PORT_22_TCP_ADDR
fi

/usr/sbin/sshd -D
