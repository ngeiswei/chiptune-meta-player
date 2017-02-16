#!/bin/bash

# Play chiptunes in random order from various sources.

# Usage
#
# chiptune-meta-player.sh [update] [FMT-1] ... [FMT-n]
#
# where FMT-1 to FMT-n are the chiptune formats you would like to
# play, or update if the optional update command is used. If no format
# are indicated then all supported formats are considered.
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

# set -x

############
# Contants #
############

# Music path
MUSIC_PATH=~/Music

# m1 program path
M1_PATH=~/Sources/m1_078a6
M1_PRG_PATH="$M1_PATH/m1-x64"
M1_XML_PATH="$M1_PATH//m1.xml"
M1_INI_PATH="$M1_PATH//m1.ini"

# Config directory
CMP_CONFIG_PATH=~/.chiptune-meta-player

# List of suported formats
SUPPORTED_FMTS=(m1 mod sid)

#############
# Functions #
#############

# Info level logging
infoEcho() {
    echo "[INFO] $@"
}

# Warning level logging on stderr
warning() {
    echo "[WARN] $@" 1>&2
}

# Error level logging on stderr and exit
fatalError() {
    echo "[ERROR] $@" 1>&2
    exit 1
}

# Create files ".<FMT>" with the list of all file paths of the
# provided formats.
update() {
    infoEcho "update"
    while [[ $# > 0 ]]; do
        update_fmt "$1"
        shift
    done
}

# Create file ".<FMT>" with the list of all file paths of that
# format. The format m1 is treated seperatly.
update_fmt() {
    local fmt="$1"
    infoEcho "search chiptunes in $MUSIC_PATH with format $fmt"
    if [[ "$fmt" == m1 ]]; then
        "$M1_PRG_PATH" -ll > $CMP_CONFIG_PATH/"$fmt"
    else
        find $MUSIC_PATH -name "*.$fmt" > $CMP_CONFIG_PATH/"$fmt"
    fi
}

get_existing_fmts() {
    local res=($(find "$CMP_CONFIG_PATH" -name "*" -exec basename {} \;))
    unset res[0]
    echo ${res[@]}
}

# Randomly select the format for the song to play
select_fmt() {
    if [[ $# > 0 ]]; then
        local fmts=("$@")
    else
        # If no format is specified choose between the existing known
        # ones
        local fmts=($(get_existing_fmts))
    fi
    local fmt_index=$((RANDOM % ${#fmts}))
    echo ${fmts[$fmt_index]}
}

# Return command line to play the given format
fmt2cmd() {
    local fmt="$1"
    case "$fmt" in
        "m1")
            echo "\"$M1_PRG_PATH\" -m0 -n -v5"
            ;;
        "sid")
            echo sidplay2
            ;;
        "mod" | "xm")
            echo "xmp -l"
            ;;
        *)
            fatalError "Format $fmt is not supported"
            ;;
    esac
}

# Random select a song of the given format
select_song() {
    local fmt="$1"
    local songs="$CMP_CONFIG_PATH/$fmt"
    case "$fmt" in
        "m1")
            echo "$(shuf < "$songs" | head -n1 | cut -d: -f1)"
            ;;
        *)
            echo "$(shuf < "$songs" | head -n1)"
    esac
}

########
# Main #
########

# Create config path
mkdir $CMP_CONFIG_PATH &> /dev/null

# Copy m1 xml file to current directory, otherwise m1 doesn't work, I
# don't know why.
cp $M1_XML_PATH .
cp $M1_INI_PATH .

# First time or user update
if [[ -z $(get_existing_fmts) || "$1" == update ]]; then
    shift
    if [[ $# == 0 ]]; then
        update ${SUPPORTED_FMTS[@]}
    else
        update $@
    fi
    exit 0
fi

# Pick up the chiptune format
fmt="$(select_fmt $@)"
infoEcho "Select $fmt format"

# Pick up the song to play
song="$(select_song "$fmt")"
infoEcho "Select $song"

# Build the command line and play the song
cmd="$(fmt2cmd "$fmt") \"$song\""
infoEcho "$cmd"
eval "$cmd"
