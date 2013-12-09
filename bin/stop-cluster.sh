#! /bin/bash

set -e

if docker -H=$DOCKER_API_HOST ps | grep "hectcastro/riak" >/dev/null; then
  for index in {1 2 3 4 5};
  do
    docker -H=$DOCKER_API_HOST stop riak0$index >/dev/null
    docker -H=$DOCKER_API_HOST rm riak0$index >/dev/null
  done

  echo "Stopped the cluster and cleared all of the running containers."
fi
