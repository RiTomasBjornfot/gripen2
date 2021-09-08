#!/usr/bin/bash
UNIT=$1
rm data/$1_*
rm fifo/$1 
mkfifo fifo/$1 
echo "Connecting to unit "$1 $(date)
./read_ble.py $1
echo "done: "$(date)
