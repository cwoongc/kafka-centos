#!/bin/bash

echo "1. Set local variables"
echo "node_no=$1"
node_no=$1
zk_hostname="wcchoi-zk00$node_no"
kafka_hostname="wcchoi-kafka00$node_no"
ipaddr=$(ifconfig | grep -a1 eth0 | grep "inet" | awk '{print $2}')

echo "2. Create a zookeeper node id file"
echo $node_no > /data/myid

echo "3. Set the hostnames into /etc/hosts file"
grep -q "$zk_hostname" /etc/hosts || echo "$ipaddr $zk_hostname" >> /etc/hosts
grep -q "$kafka_hostname" /etc/hosts || echo "$ipaddr $kafka_hostname" >> /etc/hosts

#echo "4. Reload systemd"
#systemctl deamon-reload

#echo "5. Start zookeeper-server.service"
#systemctl start zookeeper-server.service 

echo "4. Start zookeeper"
/usr/local/zookeeper/bin/zkServer.sh start

echo "5. Modify kafka's server.properties file"
kafka_server_properties=/usr/local/kafka/config/server.properties
sed -i "s/broker.id=0/broker.id=$node_no/g" $kafka_server_properties
sed -i "s/log.dirs=\/tmp\/kafka-logs/log.dirs=\/data1,\/data2/g" $kafka_server_properties
sed -i "s/zookeeper.connect=localhost:2181/zookeeper.connect=wcchoi-zk001:2181,wcchoi-zk002:2181,wcchoi-zk003:2181\/wcchoi-kafka/g" $kafka_server_properties
sed -i "s/offsets.topic.replication.factor=1/offsets.topic.replication.factor=3/g" $kafka_server_properties
sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/wcchoi-kafka00${node_no}:${node_no}9092/g" $kafka_server_properties
sed -i "s/#advertised.listeners=PLAINTEXT:\/\/your.host.name:9092/advertised.listeners=PLAINTEXT:\/\/wcchoi-kafka00${node_no}:${node_no}9092/g" $kafka_server_properties
echo -e "\nunclean.leader.election.enable = true\ndelete.topic.enable=true\nport=${node_no}9092\n" >> $kafka_server_properties


#echo "6. Start kafka"
#/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &

tail -f /dev/null
