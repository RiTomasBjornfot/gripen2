#!/usr/bin/bash
./read_ble.sh $1 &
./calc_ble.jl $1 
echo "done..."
