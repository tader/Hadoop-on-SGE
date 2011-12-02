#!/bin/bash

. $SGE_O_WORKDIR/lib.sh

export DEFAULT_CONF="$HADOOP_HOME/conf"
export CONF="$BASE_PATH/conf"
export HADOOP_CONF_DIR="$CONF"
export HADOOP_LOG_DIR="$CONF/logs"
export HADOOP_PID_DIR="$CONF/pids"
export HADOOP_MASTERS="$CONF/masters"
export HADOOP_SLAVES="$CONF/slaves"

if [ -e "$SHUTDOWN_PLEASE" ]; then
    rm -f "$SHUTDOWN_PLEASE"
fi

function generate_config() {
    # Populate CONF for this job
    if [ ! -d $CONF           ]; then mkdir -p $CONF;           fi
    if [ ! -d $HADOOP_LOG_DIR ]; then mkdir -p $HADOOP_LOG_DIR; fi
    if [ ! -d $HADOOP_PID_DIR ]; then mkdir -p $HADOOP_PID_DIR; fi

	cp $DEFAULT_CONF/* $CONF/

	# Create a new hadoop-site.xml for this job in the grid.
	cp $TEMPLATE $CONF/core-site.xml

    # Escape for sed replacement
    # See: http://stackoverflow.com/questions/407523/escape-a-string-for-sed-search-pattern

    _HOSTNAME=$(echo "${HOSTNAME}"|sed -e 's/\(\/\|\\\|&\)/\\&/g')
    _HADOOP_TEMP_DIR=$(echo "${HADOOP_TEMP_DIR}"|sed -e 's/\(\/\|\\\|&\)/\\&/g')

    sed -i "s/%%MASTER%%/$_HOSTNAME/g" $CONF/core-site.xml
    sed -i "s/%%HADOOP_TEMP_DIR%%/$_HADOOP_TEMP_DIR/g" $CONF/core-site.xml
    cp $CONF/core-site.xml $CONF/mapred-site.xml
    cp $CONF/core-site.xml $CONF/hdfs-site.xml

    rm $CONF/masters
    rm $CONF/slaves
}

function generate_masters_file() {
    echo "$HOSTNAME" >$HADOOP_MASTERS
}

function generate_slaves_file() {
    echo "$HOSTNAME" >>$HADOOP_SLAVES
}

function hadoop_start_master() {
    generate_config
    generate_masters_file

    $HADOOP_HOME/bin/hadoop --config $CONF namenode -format

    barrier # initialized

    hadoop_really_start_master
}

function hadoop_really_start_master() {
	$HADOOP_HOME/bin/hadoop --config $CONF namenode &
    echo $! >>"$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"

	$HADOOP_HOME/bin/hadoop --config $CONF secondarynamenode & 
    echo $! >>"$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"

	$HADOOP_HOME/bin/hadoop --config $CONF jobtracker & 
    echo $! >>"$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"
}

function hadoop_start_slave() {
    barrier # initialized

    hadoop_really_start_slave
}

function hadoop_really_start_slave() {
	$HADOOP_HOME/bin/hadoop --config $CONF datanode -Ddfs.datanode.hostname=$HOSTNAME & 
    echo $! >>"$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"

	$HADOOP_HOME/bin/hadoop --config $CONF tasktracker &
    echo $! >>"$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"
}

hadoop_start() {
    if [ "$SGE_TASK_ID" -eq "$SGE_TASK_FIRST" ]
    then
        hadoop_start_master
    else
        hadoop_start_slave
    fi
}

hadoop_stop() {
    KILLED=0
    for PID in `cat "$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"`
    do
        if [ -d "/proc/$PID" ]; then
            kill ${PID}
            KILLED=$(($KILLED+1))
        fi
    done

    if [ "$KILLED" -ne "0" ]; then
        for SLEEP in 1 2 3 4 5 6 7 8 9 10; do
            KILLED=0
            for PID in `cat "$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"`
            do
                if [ -d "/proc/$PID" ]; then
                    if [ "$SLEEP" -gt "7" ]; then
                        kill -9 ${PID}
                    else
                        kill ${PID}
                    fi
                    KILLED=$(($KILLED+1))
                fi
            done
            if [ "$KILLED" -eq "0" ]; then
                break
            else
                sleep $SLEEP
            fi
        done
    fi

    rm "$BASE_PATH/pids_$JOB_ID.$SGE_TASK_ID"
    rm -rf "$HADOOP_TEMP_DIR"
    rm -rf "/tmp/Jetty*"
}
