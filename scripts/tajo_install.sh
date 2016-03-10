#!/usr/bin/env bash

export PROJ_DIR=/home/vagrant
export SERVERS=/vagrant/servers
#export SERVERS=/Users/dhong/Documents/workspace/etc/tz-tajo/servers
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export HADOOP_HOME=/home/vagrant/hadoop-2.7.2
export TAJO_MASTER_HEAPSIZE=1000
export TAJO_HOME=/vagrant/servers/tajo-master
export TAJO_WORKER_HEAPSIZE=5000
export TAJO_PID_DIR=${TAJO_HOME}/pids
export TAJO_LOG_DIR=${TAJO_HOME}/logs

cd $SERVERS
wget http://apache.mirror.cdnetworks.com/tajo/tajo-0.11.1/tajo-0.11.1.tar.gz
tar xvf tajo-0.11.1.tar.gz
cd tajo-0.11.1

cp -Rf $SERVERS/configs/tajo/conf/tajo-site.xml $SERVERS/tajo-0.11.1/conf 
cp -Rf $SERVERS/configs/tajo/conf/workers $SERVERS/tajo-0.11.1/conf 

cd $SERVERS
tar cvfz tajo.tar.gz tajo-0.11.1
mv tajo-0.11.1 tajo-master

exit 0

mkdir -p $SERVERS/tmp
scp tajo.tar.gz vagrant@slave01:/vagrant/servers/tmp/tajo1.tar.gz
scp tajo.tar.gz vagrant@slave02:/vagrant/servers/tmp/tajo2.tar.gz
scp tajo.tar.gz vagrant@slave03:/vagrant/servers/tmp/tajo3.tar.gz

ssh vagrant@slave01 "cd /vagrant/servers/tmp; tar xvf tajo1.tar.gz; mv tajo-0.11.1 slave01; mv slave01 .."
ssh vagrant@slave02 "cd /vagrant/servers/tmp; tar xvf tajo2.tar.gz; mv tajo-0.11.1 slave02; mv slave02 .."
ssh vagrant@slave03 "cd /vagrant/servers/tmp; tar xvf tajo3.tar.gz; mv tajo-0.11.1 slave03; mv slave03 .."

ssh vagrant@slave01 "cd /vagrant/scripts; bash tajo_run.sh slave01"
ssh vagrant@slave02 "cd /vagrant/scripts; bash tajo_run.sh slave02"
ssh vagrant@slave03 "cd /vagrant/scripts; bash tajo_run.sh slave03"

exit 0
