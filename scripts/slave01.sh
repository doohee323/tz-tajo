#!/usr/bin/env bash

# change hosts
echo '' >> /etc/hosts
echo '# for vm' >> /etc/hosts
echo '192.168.82.170	master01' >> /etc/hosts
echo '192.168.82.171	slave01' >> /etc/hosts
echo '192.168.82.172	slave02' >> /etc/hosts
echo '192.168.82.173	slave03' >> /etc/hosts

echo "Reading config...." >&2
source /vagrant/setup.rc

apt-get -y -q update 
apt-get install software-properties-common python-software-properties -y
add-apt-repository ppa:webupd8team/java -y 
apt-get -y -q update 
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections 
apt-get -y -q install oracle-java8-installer 
apt-get purge openjdk* -y
apt-get install oracle-java8-set-default
apt-get install wget curl unzip -y

export NODE=slave01
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

echo '' >> $PROJ_DIR/.bashrc
echo 'export SERVERS=/vagrant/servers' >> $PROJ_DIR/.bashrc
echo 'export PATH=$PATH:.:$SERVERS/apache-storm-0.10.0/bin' >> $PROJ_DIR/.bashrc
echo 'export JAVA_HOME='$JAVA_HOME >> $PROJ_DIR/.bashrc
echo 'export HADOOP_HOME='$HADOOP_HOME >> $PROJ_DIR/.bashrc
echo 'export TAJO_HOME='$TAJO_HOME >> $PROJ_DIR/.bashrc
echo 'export TAJO_MASTER_HEAPSIZE='$TAJO_MASTER_HEAPSIZE >> $PROJ_DIR/.bashrc
echo 'export TAJO_WORKER_HEAPSIZE='$TAJO_WORKER_HEAPSIZE >> $PROJ_DIR/.bashrc
echo 'export TAJO_PID_DIR='$TAJO_PID_DIR >> $PROJ_DIR/.bashrc
echo 'export TAJO_LOG_DIR='$TAJO_LOG_DIR >> $PROJ_DIR/.bashrc
echo 'export HADOOP_PREFIX=/home/vagrant/hadoop-2.7.2' >> $PROJ_DIR/.bashrc

ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
echo '' >> /etc/ssh/ssh_config
echo '    ForwardX11 no' >> /etc/ssh/ssh_config
echo '    StrictHostKeyChecking no' >> /etc/ssh/ssh_config
sudo service ssh restart

mkdir -p $SERVERS/tmp_${NODE}
cd $SERVERS/tmp_${NODE}
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
