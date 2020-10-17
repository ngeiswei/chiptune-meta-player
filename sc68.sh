#!/bin/bash

# Wrapper around sc68 to play all tracks and repeat

# Query the number of tracks
ntracks="$(info68 "$1" -#)"

while :
do
    for i in $(seq 1 "$ntracks"); do
        sc68 "$1" --track="$i" | aplay - -t raw -c 2 -r 44100 -f S16_LE
	if [[ "$?" != 0 ]]; then
	    exit 1
	fi
    done
done
