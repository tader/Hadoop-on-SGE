#!/bin/sh

export JAVA_HOME="/usr/lib/jvm/java-1.6.0-openjdk.x86_64"
export HADOOP_HOME="/home/deruiter/opt/hadoop-0.21.0"
export BASE_PATH="$SGE_O_WORKDIR/run"
export TEMPLATE="$SGE_O_WORKDIR/core-site.xml.template"

export HADOOP_TEMP_DIR="/tmp/hadoop.tmp.$USER"
export SHUTDOWN_PLEASE="$BASE_PATH/shutdown_please"

#switch to infiniband ip address
#export HOSTNAME="`hostname -i |grep -v '^127' |head -n 1 |sed 's/^10\.141\./10\.149\./'`"

export HOSTNAME="`hostname -i |grep -v '^127' |head -n 1`"
