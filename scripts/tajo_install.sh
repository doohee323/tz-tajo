#!/usr/bin/env bash

export NODE=tajo-0.11.1
export PROJ_DIR=/home/vagrant
export SERVERS=/vagrant/servers
#export SERVERS=/Users/dhong/Documents/workspace/etc/tz-tajo/servers
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export HADOOP_HOME=/home/vagrant/hadoop-2.7.2
export TAJO_HOME=/vagrant/servers/${NODE}
export TAJO_MASTER_HEAPSIZE=1000
export TAJO_WORKER_HEAPSIZE=5000
export TAJO_PID_DIR=${TAJO_HOME}/pids
export TAJO_LOG_DIR=${TAJO_HOME}/logs

# ssh setting
mkdir ~/.ssh
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys

#ssh vagrant@slave01 "mkdir -p ~/.ssh"
#scp ~/.ssh/authorized_keys slave01:~/.ssh/.
#ssh vagrant@slave01 "chmod 755 ~/.ssh; chmod 644 ~/.ssh/authorized_keys"

mkdir -p $SERVERS/tmp_${NODE}
cd $SERVERS/tmp_${NODE}

# hadoop download
wget http://apache.arvixe.com/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz 
tar xvf hadoop-2.7.2.tar.gz
mv hadoop-2.7.2 ..
sed -ie "s/${JAVA_HOME}/"${JAVA_HOME}"/g" $SERVERS/hadoop-2.7.2/etc/hadoop/hadoop-env.sh

# tajo download
wget http://apache.mirror.cdnetworks.com/tajo/tajo-0.11.1/tajo-0.11.1.tar.gz
tar xvf tajo-0.11.1.tar.gz
mv tajo-0.11.1 ${NODE}
mv ${NODE} ..
cd ../${NODE}

cp -Rf $SERVERS/configs/tajo/conf/tajo-site.xml $SERVERS/${NODE}/conf 
cp -Rf $SERVERS/configs/tajo/conf/workers $SERVERS/${NODE}/conf 
sed -ie "s/${TAJO_HOME}/"${TAJO_HOME}"/g" $SERVERS/${NODE}/conf/tajo-env.sh

chown -Rf vagrant:vagrant $SERVERS

exit 0
