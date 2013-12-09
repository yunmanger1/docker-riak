#! /bin/bash

set -e

if docker -H=$DOCKER_API_ENDPOINT ps | grep "hectcastro/riak" >/dev/null; then
  for index in `seq 1 5`;
  do
    docker -H=$DOCKER_API_ENDPOINT stop riak0${index} >/dev/null
    docker -H=$DOCKER_API_ENDPOINT rm riak0${index} >/dev/null
  done

  echo "Stopped the cluster and cleared all of the running containers."
fi
