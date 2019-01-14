#!/bin/bash

containers=$(docker ps -a -q -f ancestor=wcchoi/kafka)

for container in $containers; do
  docker stop $container && docker rm $container
done

docker rmi wcchoi/kafka
