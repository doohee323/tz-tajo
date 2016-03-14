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

su - vagrant

export NODE=tajo-0.11.1
export PROJ_DIR=/home/vagrant
export SERVERS=/vagrant/servers
#export SERVERS=/Users/dhong/Documents/workspace/etc/tz-tajo/servers
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export HADOOP_HOME=/vagrant/servers/hadoop-2.7.2
export TAJO_HOME=/vagrant/servers/${NODE}
export TAJO_MASTER_HEAPSIZE=1000
export TAJO_WORKER_HEAPSIZE=5000
export TAJO_PID_DIR=${TAJO_HOME}/pids
export TAJO_LOG_DIR=${TAJO_HOME}/logs

echo '' >> $PROJ_DIR/.bashrc
echo 'export SERVERS=/vagrant/servers' >> $PROJ_DIR/.bashrc
echo 'export JAVA_HOME='$JAVA_HOME >> $PROJ_DIR/.bashrc
echo 'export NODE='$NODE >> $PROJ_DIR/.bashrc
echo 'export PROJ_DIR='$PROJ_DIR >> $PROJ_DIR/.bashrc
echo 'export SERVERS='$SERVERS >> $PROJ_DIR/.bashrc
echo 'export HADOOP_HOME='$HADOOP_HOME >> $PROJ_DIR/.bashrc
echo 'export TAJO_HOME='$TAJO_HOME >> $PROJ_DIR/.bashrc
echo 'export TAJO_MASTER_HEAPSIZE='$TAJO_MASTER_HEAPSIZE >> $PROJ_DIR/.bashrc
echo 'export TAJO_WORKER_HEAPSIZE='$TAJO_WORKER_HEAPSIZE >> $PROJ_DIR/.bashrc
echo 'export TAJO_PID_DIR='$TAJO_PID_DIR >> $PROJ_DIR/.bashrc
echo 'export TAJO_LOG_DIR='$TAJO_LOG_DIR >> $PROJ_DIR/.bashrc
echo 'export HADOOP_PREFIX=/vagrant/servers/hadoop-2.7.2' >> $PROJ_DIR/.bashrc
echo 'export PATH=$PATH:.:$SERVERS/apache-storm-0.10.0/bin:$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin' >> $PROJ_DIR/.bashrc

# ssh setting
mkdir -p $PROJ_DIR/.ssh
ssh-keygen -t dsa -P '' -f $PROJ_DIR/.ssh/id_dsa
cat $PROJ_DIR/.ssh/id_dsa.pub >> $PROJ_DIR/.ssh/authorized_keys
echo '' >> /etc/ssh/ssh_config
echo '    ForwardX11 no' >> /etc/ssh/ssh_config
echo '    StrictHostKeyChecking no' >> /etc/ssh/ssh_config
sudo service ssh restart

#ssh vagrant@slave01 "mkdir -p ~/.ssh"
#scp ~/.ssh/authorized_keys slave01:~/.ssh/.
#ssh vagrant@slave01 "chmod 755 ~/.ssh; chmod 644 ~/.ssh/authorized_keys"

mkdir -p $SERVERS/tmp/${NODE}
cd $SERVERS/tmp/${NODE}

# hadoop download
if [ ! -f "hadoop-2.7.2.tar.gz" ]; then
	wget http://apache.arvixe.com/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz 
fi
tar xvf hadoop-2.7.2.tar.gz
rm -Rf $SERVERS/hadoop-2.7.2
mv hadoop-2.7.2 $SERVERS
cp -Rf $SERVERS/configs/hadoop/etc/hadoop/*.* $SERVERS/hadoop-2.7.2/etc/hadoop

# tajo download
if [ ! -f "tajo-0.11.1.tar.gz" ]; then
	wget http://apache.mirror.cdnetworks.com/tajo/tajo-0.11.1/tajo-0.11.1.tar.gz
fi
tar xvf tajo-0.11.1.tar.gz
rm -Rf $SERVERS/${NODE}
mv $SERVERS/tmp/${NODE}/${NODE} $SERVERS
cd $SERVERS/${NODE}

cp -Rf $SERVERS/configs/tajo/conf/*.* $SERVERS/${NODE}/conf 
sed -ie 's/${NODE}/'${NODE}'/g' $SERVERS/${NODE}/conf/tajo-env.sh

chown -Rf vagrant:vagrant $SERVERS

ln -s $SERVERS/hadoop-2.7.2 $PROJ_DIR/hadoop-2.7.2
cd $SERVERS/hadoop-2.7.2/sbin/
./start-yarn.sh
# ./stop-yarn.sh

# http://192.168.82.170:8042/node
# http://192.168.82.170:8088/cluster

cd $TAJO_HOME/bin
./start-tajo.sh
# ./stop-tajo.sh

# http://192.168.82.170:26002
# http://192.168.82.170:26080

exit 0
