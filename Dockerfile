FROM centos:7
MAINTAINER cwoongc@gmail.com
WORKDIR /usr/local

# 1. Download and install JDK and necessary tools 
RUN yum -y install java-1.8.0-openjdk;\
yum -y install java-1.8.0-openjdk-devel;\
yum -y install wget;\
yum -y install net-tools;\
yum -y install nc;\
yum -y install telnet;

# 2. Download and unzip Zookeeper
RUN wget http://mirror.navercorp.com/apache/zookeeper/\
zookeeper-3.4.12/zookeeper-3.4.12.tar.gz;\
tar xvf zookeeper-3.4.12.tar.gz;\
ln -s zookeeper-3.4.12 zookeeper;

# 3. Create a directory for zookeeper's snapshots and transaction logs
RUN mkdir /data

# 4. Create a zookeeper zoo.cfg file
RUN echo -e "tickTime=2000\n\
initLimit=10\n\
syncLimit=5\n\
dataDir=/data\n\
clientPort=2181\n\
server.1=wcchoi-zk001:2888:3888\n\
server.2=wcchoi-zk002:2888:3888\n\
server.3=wcchoi-zk003:2888:3888\n" >> /usr/local/zookeeper/conf/zoo.cfg

# 5. Create the zookeeper-server.service file for using systemd
RUN echo -e "[Unit]\n\
Description=zookeeper-server\n\
After=network.target\n\n\
[Service]\n\
Type=forking\n\
User=root\n\
Group=root\n\
SyslogIdentifier=zookeeper-server\n\
WorkingDirectory=/usr/local/zookeeper\n\
Restart=always\n\
RestartSec=0s\n\
ExecStart=/usr/local/zookeeper/bin/zkServer.sh start\n\
ExecStop=/usr/local/zookeeper/bin/zkServer.sh stop\n" > /etc/systemd/system/zookeeper-server.service

# 6. Download and unzip Kafka
RUN wget http://mirror.navercorp.com/apache/kafka/1.0.2/kafka_2.11-1.0.2.tgz;\
tar xvf kafka_2.11-1.0.2.tgz;\
ln -s kafka_2.11-1.0.2 kafka;
#RUN wget http://mirror.navercorp.com/apache/kafka/2.1.0/kafka_2.12-2.1.0.tgz;\
#tar xvf kafka_2.12-2.1.0.tgz;\
#ln -s kafka_2.12-2.1.0 kafka;

# 7. Create a directory for zookeeper's snapshots and transaction logs
RUN mkdir -p /data1 && mkdir -p /data2

# 8. Backup kafka's sever.properties file
RUN cp /usr/local/kafka/config/server.properties /usr/local/kafka/config/server.properties.bak

# 9. Copy the docker-entrypoint.sh file into this image
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# 10. Set default $node_no is "1"
CMD ["1"]
