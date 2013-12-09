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

for index in `seq 1 5`;
do
  if [ "$index" -gt "1" ] ; then
    docker -H=$DOCKER_API_ENDPOINT run -name riak0${index} -link riak01:seed -d hectcastro/riak
  else
    docker -H=$DOCKER_API_ENDPOINT run -name riak0${index} -d hectcastro/riak
  fi

  IP_ADDRESS=$(docker -H=$DOCKER_API_ENDPOINT inspect $(docker -H=$DOCKER_API_ENDPOINT ps | grep riak0${index} | cut -d" " -f1) | grep IPAddress | head -n1 | cut -d '"' -f4 | tr -d "\n")

  until curl -s "http://$IP_ADDRESS:8098/ping" | grep "OK" >/dev/null;
  do
    sleep 3
  done
done

sleep 10

SEED_IP_ADDRESS=$(docker -H=$DOCKER_API_ENDPOINT inspect $(docker -H=$DOCKER_API_ENDPOINT ps | grep riak01 | cut -d" " -f1) | grep IPAddress | cut -d '"' -f4 | tr -d "\n")

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
