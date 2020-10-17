#!/bin/bash

# Wrapper around vgmplay to play in repeat in case the song does not loop

while :
do
    vgmplay "$1"
    if [[ "$?" != 0 ]]; then
	exit 1
    fi
done
