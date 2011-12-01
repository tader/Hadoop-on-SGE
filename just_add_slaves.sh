#!/bin/sh
#$ -cwd
#$ -N "Hadoop Slaves"
#$ -t 1-3

set -e

export SGE_TASK_ID=$(($SGE_TASK_ID+100000))

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

hadoop_really_start_slaves

trap hadoop_stop INT TERM EXIT
    while [ ! -e "$SHUTDOWN_PLEASE" ]; do
      sleep 10
    done

    hadoop_stop
trap - INT TERM EXIT

