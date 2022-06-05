FROM docker.io/arm64v8/ubuntu:14.04

MAINTAINER Yanyun <yanyunnx@gmail.com>

WORKDIR /root

# install openssh-server, openjdk and wget
RUN apt-get update && apt-get install -y openssh-server openjdk-7-jdk wget vim-gtk

# install hadoop 2.7.2
RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz && \
    tar -xzvf hadoop-2.7.2.tar.gz && \
    mv hadoop-2.7.2 /usr/local/hadoop && \
    rm hadoop-2.7.2.tar.gz

# install hive 2.1.1
RUN wget https://archive.apache.org/dist/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz && \
    tar -xzvf apache-hive-2.1.1-bin.tar.gz && \
    mv apache-hive-2.1.1-bin /usr/local/hive && \
    rm apache-hive-2.1.1-bin.tar.gz

# install flume 1.7.0
RUN wget https://github.com/apache/flume/archive/refs/tags/release-1.7.0-rc2.tar.gz && \
    tar -xzvf release-1.7.0-rc2.tar.gz && \
    mv flume-release-1.7.0-rc2 /usr/local/flume && \
    rm release-1.7.0-rc2.tar.gz

# install sqoop 1.7.0
RUN wget http://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    tar -xzvf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz && \
    mv sqoop-1.4.7.bin__hadoop-2.6.0 /usr/local/sqoop && \
    rm sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-7-openjdk-arm64
ENV HADOOP_HOME=/usr/local/hadoop 
ENV HIVE_HOME=/usr/local/hive
ENV FLUME_HOME=/usr/local/flume
ENV SQOOP_HOME=/usr/local/sqoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$FLUME_HOME/bin:$SQOOP_HOME/bin


# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir -p /tmp/hadoop && \
    mkdir -p /tmp/hive && \
    mkdir $HADOOP_HOME/logs

COPY config/hadoop/* /tmp/hadoop/
COPY config/hive /tmp/hive/
COPY config/flume /tmp/flume/
COPY config/sqoop /tmp/sqoop/

RUN mv /tmp/hadoop/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/hadoop/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/hadoop/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/hadoop/run-wordcount.sh ~/run-wordcount.sh && \
    mv /tmp/hive/mysql-connector-java-5.1.47.jar $HIVE_HOME/lib/mysql-connector-java-5.1.47.jar && \
    mv /tmp/hive/hive-site.xml $HIVE_HOME/conf/hive-site.xml && \
    mv /tmp/hive/hive-env.sh $HIVE_HOME/conf/hive-env.sh && \
    mv /tmp/hive/start-hive.sh ~/start-hive.sh && \
    mv /tmp/flume/flume-conf.properties $FLUME_HOME/conf/flume-conf.properties && \
    mv /tmp/flume/flume-env.sh $FLUME_HOME/conf/flume-env.sh && \
    mv /tmp/sqoop/sqoop-env.sh $SQOOP_HOME/conf/sqoop-env.sh && \
    cp $HIVE_HOME/lib/mysql-connector-java-5.1.47.jar $SQOOP_HOME/lib/mysql-connector-java-5.1.47.jar && \
    mv /tmp/sqoop/sqoop-site.xml $SQOOP_HOME/conf/sqoop-site.xml


RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

CMD [ "sh", "-c", "service ssh start; bash"]

