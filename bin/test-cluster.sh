#! /bin/bash

set -e

SEED_IP_ADDRESS=$(docker -H=$DOCKER_API_HOST inspect $(docker -H=$DOCKER_API_HOST ps | grep riak01 | cut -d" " -f1) | grep IPAddress | cut -d '"' -f4)

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@$SEED_IP_ADDRESS \
    riak-admin ringready
