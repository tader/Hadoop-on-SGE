#!/bin/sh
#$ -cwd
#$ -N Hadoop
#$ -t 1-3

set -e

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

hadoop_start

trap "hadoop_stop" INT TERM EXIT

    while [ ! -e "$BASE_PATH/shutdown_please" ]; do
      sleep 10
    done

trap - INT TERM EXIT

hadoop_stop
