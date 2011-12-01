#!/bin/sh
#$ -cwd
#$ -N "Hadoop Slaves"
#$ -t 1-13
#$ -l h_rt=24:00:00

set -e

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

hadoop_really_start_slave

trap hadoop_stop INT TERM EXIT
    while [ ! -e "$SHUTDOWN_PLEASE" ]; do
      sleep 10
    done

    hadoop_stop
trap - INT TERM EXIT

