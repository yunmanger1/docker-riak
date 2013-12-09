#! /bin/bash

set -e

if docker -H=$DOCKER_API_ENDPOINT ps | grep "hectcastro/riak" >/dev/null; then
  echo ""
  echo "It looks like you already have some containers running."
  echo "Please take them down before attempting to bring up another"
  echo "cluster with the following command:"
  echo ""
  echo "  make stop-cluster"
  echo ""

  exit 1
fi

docker -H=$DOCKER_API_ENDPOINT run -name riak01 -d hectcastro/riak
docker -H=$DOCKER_API_ENDPOINT run -name riak02 -link riak01:seed -d hectcastro/riak
docker -H=$DOCKER_API_ENDPOINT run -name riak03 -link riak01:seed -d hectcastro/riak
docker -H=$DOCKER_API_ENDPOINT run -name riak04 -link riak01:seed -d hectcastro/riak
docker -H=$DOCKER_API_ENDPOINT run -name riak05 -link riak01:seed -d hectcastro/riak

SEED_IP_ADDRESS=$(docker -H=$DOCKER_API_ENDPOINT inspect $(docker -H=$DOCKER_API_ENDPOINT ps | grep riak01 | cut -d" " -f1) | grep IPAddress | cut -d '"' -f4)

sshpass -p "basho" \
  ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@$SEED_IP_ADDRESS \
    riak-admin cluster plan

read -p "Commit these cluster changes? (y/n): " RESP
if [[ $RESP =~ ^[Yy]$ ]] ; then
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@$SEED_IP_ADDRESS \
      riak-admin cluster commit
else
  sshpass -p "basho" \
    ssh -o "StrictHostKeyChecking no" -o "UserKnownHostsFile /dev/null" -o "LogLevel quiet" root@$SEED_IP_ADDRESS \
      riak-admin cluster clear
fi
