#!/bin/bash

ECHOE="echo -e"
[ "$(echo -e)" = "-e" ] && ECHOE="echo"


ID=$(id -u)

COMPUTER_NAME=$(whoami)

HADOOP_PATH=/usr/local/hadoop/etc/hadoop/


isUserRoot() {
    if [ $ID -ne 0 ]; then
        echo "$CMD must be run as 'root'"
exit -1
    fi

}

centerMsg() {
    width=$(tput cols)
    $ECHOE "$1" | awk '{ spaces = ('$width' - length) / 2
      while (spaces-- >= 1) printf (" ")
      print
    }'
}

updates() {
	sudo apt-get update
	sudo apt-get install build-essential
	sudo apt-get upgrade
}

prologue() {
    tput clear
    tput bold
    centerMsg "\nSingle Node Hadoop Kurulumu\n"
    centerMsg "Copyright $(date +%Y) EDSOFT"
    centerMsg "http://edceo.blogspot.com"
    tput sgr0
    checkOS
}

checkOS() {
    
    if [ -f /etc/redhat-release ]; then
        OS=redhat
centerMsg "Lütfen 64 bit Ubuntu İşletim Sistemi kullanın"
exit 1
    elif [ -f /etc/SuSE-release ]; then
        OS=suse
centerMsg "Lütfen 64 bit Ubuntu İşletim Sistemi kullanın"
exit 1
    elif uname -a | grep -q -i "ubuntu"; then
        OS=ubuntu
    else
        centerMsg "Lütfen 64 bit Ubuntu İşletim Sistemi kullanın"
    fi
    if [ $(uname -p) != "x86_64" ]; then
        centerMsg "Lütfen 64 bit Ubuntu İşletim Sistemi kullanın"
    fi

}
formatMsg() {
    WORDS=$1
    LENGTH=0
    width=$(tput cols)
    for WORD in $WORDS; do
        LENGTH=$(($LENGTH + ${#WORD} + 1))
        if [ $LENGTH -gt $width ]; then
            $ECHOE "\n$WORD \c" 
            LENGTH=$((${#WORD} + 1))
        else
            $ECHOE "$WORD \c" 
        fi
    done
    if [ $# -eq 1 ]; then
        $ECHOE "\n" 
    fi
}
testJDK() {
    # if keytool exists, then JDK has been installed
    formatMsg "\nTesting for JDK 7 or 8..."
    if [ -n "$JAVA_HOME" ]; then
        KEYTOOL=$JAVA_HOME/bin/keytool
    else
        KEYTOOL=$(which keytool 2>/dev/null)
    fi

    # check if keytool is actually valid and exists
    if [ ! -e "${KEYTOOL:-}" ]; then
        formatMsg "JDK 1.7 or 1.8 not found or JAVA_HOME not set properly"
        fetchJDK 
    elif echo "$KEYTOOL" | grep -q "1.7|1.8"; then
        formatMsg "JDK not 1.7 or 1.8 not found"
        fetchJDK 
    fi
    formatMsg "...Success"
}
fetchJDK() {

    sudo add-apt-repository ppa:webupd8team/java
formatMsg "\n Repository Eklendi...."
sudo apt-get update
formatMsg "\n Oracle 8 JDK Yükleniyor...."
sudo apt-get install oracle-java8-installer
formatMsg "\n Yükleme Tamamlandı...."
}

configuringJDK() {

centerMsg "\n Java Ayarları yapılıyor..."
sudo apt-get install oracle-java8-set-default

sudo update-java-alternatives -s java-8-oracle
centerMsg "\n Java Ayarları yapıldı."

}

sshConfiguring() {
centerMsg "\n SSH Ayarları yapılıyor..."
sudo apt-get install ssh

 sudo apt-get install rsync

 ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa

 cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
centerMsg "\n SSH Ayarları yapıldı."
}

hadoopOperations() {
centerMsg "\n Hadoop İndirilmeye Başlandı..."
wget -c ftp://ftp.itu.edu.tr/Mirror/Apache/hadoop/common/hadoop-2.7.1/hadoop-2.7.1.tar.gz
centerMsg "\n Hadoop İndirilme Tamamlandı."
centerMsg "\n Klasör çıkartılıyor ve taşınıyor..."
sudo tar -zxvf hadoop-2.7.1.tar.gz
sudo mv hadoop-2.7.1 /usr/local/hadoop
centerMsg "\n İşlem Tamamlandı."
}

configuringBash() {

centerMsg "Bash Dosyası Düzenleniyor..."
sudo echo 'export JAVA_HOME=/usr/lib/jvm/java-8-oracle
          export HADOOP_HOME=/usr/local/hadoop
          export PATH=$PATH:$HADOOP_HOME/bin
          export PATH=$PATH:$HADOOP_HOME/sbin
          export HADOOP_MAPRED_HOME=$HADOOP_HOME
          export HADOOP_COMMON_HOME=$HADOOP_HOME
          export HADOOP_HDFS_HOME=$HADOOP_HOME
          export YARN_HOME=$HADOOP_HOME
          export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
          export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"' >> .bashrc

source .bashrc

centerMsg "\nBash Dosyası düzenlendi"

}

configuringXMLs() {

centerMsg "\nXML Dosyaları Düzenleniyor"

writeXMLs


centerMsg "\nXML Dosyaları Düzenlendi. "
sudo mkdir -p /usr/local/hadoop/hadoop_data/hdfs/namenode
sudo mkdir -p /usr/local/hadoop/hadoop_data/hdfs/datanode

centerMsg "\nKlasörler oluşturuldu."

}

accessAndRunning() {

centerMsg "\nHADOOP BAŞARIYLA YÜKLENDİ."

centerMsg "\n Hadoop Çalıştırmak için aşağıdaki adımları sırayla yapınız"

formatMsg "\n1)sudo chown username:username -R /usr/local/hadoop"
formatMsg "\n2)hdfs namenode -format"
formatMsg "\n3)start-dfs.sh"
formatMsg "\n4)start-yarn.sh"
}

writeXMLs() {
echo '# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set Hadoop-specific environment variables here.

# The only required environment variable is JAVA_HOME.  All others are
# optional.  When running a distributed configuration it is best to
# set JAVA_HOME in this file, so that it is correctly defined on
# remote nodes.

# The java implementation to use.
export JAVA_HOME="/usr/lib/jvm/java-8-oracle"

# The jsvc implementation to use. Jsvc is required to run secure datanodes
# that bind to privileged ports to provide authentication of data transfer
# protocol.  Jsvc is not required if SASL is configured for authentication of
# data transfer protocol using non-privileged ports.
#export JSVC_HOME=${JSVC_HOME}

export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-"/etc/hadoop"}

# Extra Java CLASSPATH elements.  Automatically insert capacity-scheduler.
for f in $HADOOP_HOME/contrib/capacity-scheduler/*.jar; do
  if [ "$HADOOP_CLASSPATH" ]; then
    export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$f
  else
    export HADOOP_CLASSPATH=$f
  fi
done

# The maximum amount of heap to use, in MB. Default is 1000.
#export HADOOP_HEAPSIZE=
#export HADOOP_NAMENODE_INIT_HEAPSIZE=""

# Extra Java runtime options.  Empty by default.
export HADOOP_OPTS="$HADOOP_OPTS -Djava.net.preferIPv4Stack=true"

# Command specific options appended to HADOOP_OPTS when specified
export HADOOP_NAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_NAMENODE_OPTS"
export HADOOP_DATANODE_OPTS="-Dhadoop.security.logger=ERROR,RFAS $HADOOP_DATANODE_OPTS"

export HADOOP_SECONDARYNAMENODE_OPTS="-Dhadoop.security.logger=${HADOOP_SECURITY_LOGGER:-INFO,RFAS} -Dhdfs.audit.logger=${HDFS_AUDIT_LOGGER:-INFO,NullAppender} $HADOOP_SECONDARYNAMENODE_OPTS"

export HADOOP_NFS3_OPTS="$HADOOP_NFS3_OPTS"
export HADOOP_PORTMAP_OPTS="-Xmx512m $HADOOP_PORTMAP_OPTS"

# The following applies to multiple commands (fs, dfs, fsck, distcp etc)
export HADOOP_CLIENT_OPTS="-Xmx512m $HADOOP_CLIENT_OPTS"
#HADOOP_JAVA_PLATFORM_OPTS="-XX:-UsePerfData $HADOOP_JAVA_PLATFORM_OPTS"

# On secure datanodes, user to run the datanode as after dropping privileges.
# This **MUST** be uncommented to enable secure HDFS if using privileged ports
# to provide authentication of data transfer protocol.  This **MUST NOT** be
# defined if SASL is configured for authentication of data transfer protocol
# using non-privileged ports.
export HADOOP_SECURE_DN_USER=${HADOOP_SECURE_DN_USER}

# Where log files are stored.  $HADOOP_HOME/logs by default.
#export HADOOP_LOG_DIR=${HADOOP_LOG_DIR}/$USER

# Where log files are stored in the secure data environment.
export HADOOP_SECURE_DN_LOG_DIR=${HADOOP_LOG_DIR}/${HADOOP_HDFS_USER}

###
# HDFS Mover specific parameters
###
# Specify the JVM options to be used when starting the HDFS Mover.
# These options will be appended to the options specified as HADOOP_OPTS
# and therefore may override any similar flags set in HADOOP_OPTS
#
# export HADOOP_MOVER_OPTS=""

###
# Advanced Users Only!
###

# The directory where pid files are stored. /tmp by default.
# NOTE: this should be set to a directory that can only be written to by 
#       the user that will run the hadoop daemons.  Otherwise there is the
#       potential for a symlink attack.
export HADOOP_PID_DIR=${HADOOP_PID_DIR}
export HADOOP_SECURE_DN_PID_DIR=${HADOOP_PID_DIR}

# A string representing this instance of hadoop. $USER by default.
export HADOOP_IDENT_STRING=$USER' > $HADOOP_PATH"hadoop-env.sh"
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
                      <name>fs.defaultFS</name>
                      <value>hdfs://localhost:8020</value>
                  </property>
</configuration>' > $HADOOP_PATH"core-site.xml"
echo '<?xml version="1.0"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->
<configuration>

<!-- Site specific YARN configuration properties -->
<property>
                      <name>yarn.nodemanager.aux-services</name>
                      <value>mapreduce_shuffle</value>
                  </property>
                  <property>
                      <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
                      <value> org.apache.hadoop.mapred.ShuffleHandler</value>
                  </property>
</configuration>' > $HADOOP_PATH"yarn-site.xml"


echo '<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
                      <name>mapreduce.framework.name</name>
                      <value>yarn</value>
                  </property>
</configuration>' > $HADOOP_PATH"mapred-site.xml"
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
 <property>
                      <name>dfs.replication</name>
                      <value>1</value>
                  </property>
                  <property>
                      <name>dfs.namenode.name.dir</name>
                      <value>file:/usr/local/hadoop/hadoop_data/hdfs/namenode</value>
                  </property>
                  <property>
                      <name>dfs.datanode.data.dir</name>
                      <value>file:/usr/local/hadoop/hadoop_store/hdfs/datanode</value>
                  </property>
</configuration>' > $HADOOP_PATH"hdfs-site.xml"

}

#
#MAIN
#
isUserRoot
checkOS
prologue
updates
fetchJDK
testJDK
configuringJDK
sshConfiguring
hadoopOperations
configuringBash
configuringXMLs
accessAndRunning
