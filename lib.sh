#!/bin/sh

#
# The function barrier waits for all nodes,
# and continues if all are present.
#

BARRIER_COUNTER=0

barrier() {
  SLEEP_TIME="0.1"
  BARRIER_COUNTER="$(($BARRIER_COUNTER + 1))"
  NAME="BARRIER_$BARRIER_COUNTER"

  BARRIER_FILE_MINE="$NAME.$SGE_TASK_ID"
  BARRIER_FILE_MASTER="$NAME.$SGE_TASK_FIRST"

  if [ "$SGE_TASK_FIRST" -eq "$SGE_TASK_ID" ]; then
    WAIT_FOR_SLAVES=1
    while [ "$WAIT_FOR_SLAVES" -eq "1" ]; do
      ALL_SLAVES_THERE=1
      for SLAVE in `seq $SGE_TASK_FIRST $SGE_TASK_STEPSIZE $SGE_TASK_LAST`; do
        if [ ! "$SGE_TASK_FIRST" -eq "$SLAVE" ]; then
          if [ ! -e "$NAME.$SLAVE" ]; then
            ALL_SLAVES_THERE=0
          fi
        fi
      done

      if [ "$ALL_SLAVES_THERE" -eq "1" ]; then
        WAIT_FOR_SLAVES=0
      else
        sleep $SLEEP_TIME
      fi
    done

    echo 1 >"$BARRIER_FILE_MINE"

    WAIT_FOR_SLAVES=1
    while [ "$WAIT_FOR_SLAVES" -eq "1" ]; do
      ALL_SLAVES_THERE=1
      for SLAVE in `seq $SGE_TASK_FIRST $SGE_TASK_STEPSIZE $SGE_TASK_LAST`; do
        if [ ! "$SGE_TASK_FIRST" -eq "$SLAVE" ]; then
          if [ -e "$NAME.$SLAVE" ]; then
            ALL_SLAVES_THERE=0
          fi
        fi
      done

      if [ "$ALL_SLAVES_THERE" -eq "1" ]; then
        WAIT_FOR_SLAVES=0
      else
        sleep $SLEEP_TIME
      fi
    done

    rm "$BARRIER_FILE_MINE"
  else
    echo 1>"$BARRIER_FILE_MINE"
    while [ ! -e "$BARRIER_FILE_MASTER" ]; do
      sleep $SLEEP_TIME
    done
    rm "$BARRIER_FILE_MINE"
  fi
}
