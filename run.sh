#!/bin/bash

containers=$(docker ps -a -q -f ancestor=wcchoi/kafka)

if [[ -n $containers ]]
then
  echo -e "Remove the following containers first";
  echo -e "["
  for container in $containers; do
    echo -e "$container"
  done
  echo -e "]"
  exit 1
  return
fi

node_size=$1
if [[ -z "$node_size" || $node_size -le 0 ]]
then
  node_size=3
  echo -e "Apply default node size 3.\n";
fi

for ((i=1;i<=$node_size;i++)) 
do
  docker run -d --name=kafka$i -p ${i}2181:2181 -p ${i}9092:${i}9092  wcchoi/kafka $i
done

containers=$(docker ps -a -q -f ancestor=wcchoi/kafka)
rows=""
name=""
num=""

if [[ -n $containers ]]
then
  for container in $containers; do
    if [[ -n "$rows" ]]
    then
      rows="$rows\n"
    fi

    name=$(docker ps -a -f id=$container --format="{{.Names}}")
    num=$(echo $name | sed 's/[a-zA-Z]*//g')

    rows="${rows}wcchoi-zk00$num;wcchoi-kafka00$num;$name;"$(docker inspect -f "{{.NetworkSettings.IPAddress}};$container" $container)
  done
fi

rows=$(echo -e $rows)

for row1 in $rows; do
  echo $row1
  IFS=';' read -ra PROPS1 <<< "$row1"
  zk_host_name1=${PROPS1[0]}
  echo "zk_host_name1: $zk_host_name1"
  kafka_host_name1=${PROPS1[1]}
  echo "kafka_host_name1: $kafka_host_name1"
  name1=${PROPS1[2]}
  echo "name1: $name1"
  ipaddr1=${PROPS1[3]}
  echo "ipaddr1: $ipaddr1"
  container_id1=${PROPS1[4]}
  echo "container_id1: $container_id1"
  for row2 in $rows; do
    IFS=';' read -ra PROPS2 <<< "$row2"
    zk_host_name2=${PROPS2[0]}
    echo "zk_host_name2: $zk_host_name2"
    kafka_host_name2=${PROPS2[1]}
    echo "kafka_host_name2: $kafka_host_name2"
    name2=${PROPS2[2]}
    echo "name2: $name2"
    ipaddr2=${PROPS2[3]}
    echo "ipaddr2: $ipaddr2"
    container_id2=${PROPS2[4]}
    echo "container_id2: $container_id2"

    if [[ "$container_id1" != "$container_id2" ]]
    then
      docker exec -ti $container_id1 sh -c "echo $ipaddr2 $zk_host_name2 >> /etc/hosts && echo $ipaddr2 $kafka_host_name2 >> /etc/hosts"
      docker exec -it $container_id1 sh -c "nohup /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &"
    fi
  done
done
