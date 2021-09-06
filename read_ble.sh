#!/usr/bin/bash
UNIT=$1
rm data/$UNIT_*
rm fifo/$UNIT 
mkfifo fifo/$UNIT 
echo "Connecting to unit "$1
./read_ble.py units/$UNIT.json
