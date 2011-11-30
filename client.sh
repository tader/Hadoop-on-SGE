#!/bin/bash

SGE_O_WORKDIR="$(pwd)"

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

$HADOOP_HOME/bin/hadoop --config $CONF $@

