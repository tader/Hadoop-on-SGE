#!/bin/bash

SGE_O_WORKDIR="$(pwd)"

. $SGE_O_WORKDIR/settings.sh
. $SGE_O_WORKDIR/hadoop.sh

echo 1> "$SHUTDOWN_PLEASE"

echo "I created the file: $SHUTDOWN_PLEASE"
echo "Hadoop will shutdown."
