#!/bin/sh

SGE_O_WORKDIR="$(pwd)"

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

GZIP_INPUT_TRACE_FILE="$HADOOP_HOME/mapred/src/contrib/mumak/src/test/data/19-jobs.trace.json.gz"
INPUT_TRACE="$SGE_O_WORKDIR/trace.json"
DFS_INPUT_TRACE="trace.json"

IOPATH="new-iopath"
IOPATH_SIZE="1g"

GRIDMIX_JAR="$HADOOP_HOME/mapred/contrib/gridmix/hadoop-0.21.0-gridmix.jar"
GRIDMIX_CLASS="org.apache.hadoop.mapred.gridmix.Gridmix"

if [ ! -e "$INPUT_TRACE" ]; then
    gunzip -c <"$GZIP_INPUT_TRACE_FILE" >"$INPUT_TRACE"
fi

$SGE_O_WORKDIR/client.sh dfs -rm  $DFS_INPUT_TRACE
$SGE_O_WORKDIR/client.sh dfs -rmr $IOPATH

$SGE_O_WORKDIR/client.sh dfs -copyFromLocal $INPUT_TRACE                                  $DFS_INPUT_TRACE
$SGE_O_WORKDIR/client.sh jar "$GRIDMIX_JAR" $GRIDMIX_CLASS -generate $IOPATH_SIZE $IOPATH $DFS_INPUT_TRACE
$SGE_O_WORKDIR/client.sh jar "$GRIDMIX_JAR" $GRIDMIX_CLASS                        $IOPATH $DFS_INPUT_TRACE
