#!/usr/bin/env bash

export PROJ_DIR=/home/vagrant
export SERVERS=/vagrant/servers
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export HADOOP_HOME=/home/vagrant/hadoop-2.7.2
export TAJO_MASTER_HEAPSIZE=1000
# export TAJO_HOME=/vagrant/servers/tajo-0.11.1
export TAJO_HOME=/vagrant/servers/$1
export TAJO_WORKER_HEAPSIZE=5000
export TAJO_PID_DIR=${TAJO_HOME}/pids
export TAJO_LOG_DIR=${TAJO_HOME}/logs

bash $TAJO_HOME/bin/start-tajo.sh 

exit 0
