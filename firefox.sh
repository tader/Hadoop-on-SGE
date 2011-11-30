#!/bin/bash

SGE_O_WORKDIR="$(pwd)"

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

firefox http://`cat $HADOOP_MASTERS`:50030/ &

