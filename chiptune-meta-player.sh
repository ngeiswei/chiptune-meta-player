#!/bin/bash

# Play chiptunes in random order from various sources.

# Usage
#
# chiptune-meta-player.sh [update] [FMT-1] ... [FMT-n]
#
# where FMT-1 to FMT-n are the chiptune formats you would like to
# play.
#
# How does it work?
#
# The first it is being launched it will automatically perform an
# update, that is search your ~/Music directory for all chiptune
# files, as well as possibly your ~/mame directory for MAME music. You
# may change these directories by modifying the variables MUSIC_PATH
# and MAME_PATH respectively in this file.
#
# You may at any time redo the update by typing update as first
# argument of the command, see Usage.
#
# If no argument is given then all known formats will be considered.
#
# What it will do is randomly select a format amongst the probided
# ones and then randomly select a chiptune in that format, and play
# that chiptune in loop.
#
# For now supported formats are sid, mod, as well as all supported
# formats by xmp, and m1 for MAME.

############
# Contants #
############

# Music path
MUSIC_PATH=~/Music

# Config directory
CMP_CONFIG_PATH=~/.chiptune-meta-player

#############
# Functions #
#############

# Create files ".<FMT>" with the list of all file paths of the
# provided formats.
update() {
    while [[ $# > 0 ]]; do
        update_fmt "$1"
        shift
    done
}

# Create file ".<FMT>" with the list of all file paths of that format
update_fmt() {
    find $MUSIC_PATH -name "*.$1" > $CMP_CONFIG_PATH/".$1"
}

########
# Main #
########

# Create config path
mkdir $CMP_CONFIG_PATH &> /dev/null

# Update
if [[ "$1" == update ]]; then
    update
    shift
fi

# Get the chiptune formats
# TODO
