#!/bin/bash

# Wrapper around vgmplay to play in repeat in case the song does not loop

trap_ctrlc() {
    exit 2
}

trap "trap_ctrlc" 2

while :
do
    vgmplay "$1"
    echo "$?"
done
