#!/bin/sh
#$ -cwd
#$ -N testing
#$ -t 1-3

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

hadoop_start

sleep 600

hadoop_stop
