#!/bin/bash

# Invoke chiptune-meta-player.sh a certain number of loop. The number
# of loops is provided by the first argument, and the other arguments
# are directly passed to chiptune-meta-player.sh

#############
# Functions #
#############

# Info level logging
infoEcho() {
    echo "[INFO] $@"
}

########
# Main #
########

if [[ $# == 0 ]]; then
    echo "Usage: $0 NUMBER_OF_LOOPS [ARGUMENTS-FOR-CHIPTUNE-META-PLAYER]"
    exit 1
fi

LOOP="$1"
shift
for i in $(seq 1 "$LOOP"); do
    infoEcho "Play $i/$LOOP"
    ./chiptune-meta-player.sh $@
done
