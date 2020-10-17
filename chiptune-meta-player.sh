#!/bin/bash

# Play chiptunes in random order from various sources.

# Usage
#
# chiptune-meta-player.sh [update|list] [FMT-1] ... [FMT-n] [STR-1] ... [STR-m]
#
# where FMT-1 to FMT-n are the chiptune formats you would like to
# play, or update if the optional update command is used. If no format
# are indicated then all supported formats are considered. STR-1 to
# STR-m are any strings that you want to appear in the filepaths or
# filenames. Formats and strings can be given in any order, it will
# automatically recognize what are formats and what are strings.
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
# Supported formats are sid, mod, sc68, m1 for MAME, and countless
# others. Type
#
# chiptune-meta-player.sh list
#
# to list them all.

# set -x

############
# Contants #
############

# Program path
PRG_PATH="$(readlink -f "$0")"
PRG_DIR="$(dirname "$PRG_PATH")"

# Music path
MUSIC_PATH=~/Music

# m1 program path
M1_PATH=~/Sources/m1_078a6
M1_PRG_PATH="$M1_PATH/m1-x64"
M1_XML_PATH="$M1_PATH/m1.xml"
M1_INI_PATH="$M1_PATH/m1.ini"

# Config directory
CMP_CONFIG_PATH=~/.chiptune-meta-player

# List of suported formats
M1_FMTS=() #m1)
SIDPLAY2_FMTS=(psid) # ideally should support sid as well, although this conflict with SidMon 1
XMP_FMTS=(mod xm it stm s3m mtm imf ptm ult liq psm amf gdm rtm mgt far 669 fnk ntp)
UADE_FMTS=(amc amm aon ahx cm dz dl dw cus dm dp digi dmu ems tf fred smod gmc hip hip7 hipc is is20 jmf jam kh lme mc mso md ma mmd0 mmd1 mmd2 mmd3 mmdc okta dat ps snk pvp pap pt puma emod riff rh dum rho scumm scn scr mok sc sfx st26 jd sas sb sun syn synmod thm sg wb ymst) 
SC68_FMTS=(sc68 sndh)
AYLET_FMTS=() #ay) now supported by audacious
AUDACIOUS_FMTS=(ay gbs hes nsf nsfe spc psf)
ASAP_FMTS=(sap cmc cm3 cmr cms dmc dlt mpt mpd rmt tmc tm8 tm2 fc)
MIDI_FMTS=(mid)
VGMPLAY_FMTS=(vgm vgz cmf dro)

# The following formats are in conflicts or do not work:
#
# gray is in conflict with ay
#
# ims, ss do not work
#
# bss is in conflict with ss
#
# ast is in conflict between Actionamics and All Sound Tracker
#
# psf conflict between SoundFactory and Playstation Sound Format
#
# gyn supposed to be supported by audacious but doesn't work

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
        find -L $MUSIC_PATH -iname "*.$fmt" > $CMP_CONFIG_PATH/"$fmt"
    fi
}

# Get the list of all non empty format files
get_existing_fmts() {
    local res=($(find "$CMP_CONFIG_PATH" -name "*" ! -size 0 -exec basename {} \;))
    unset res[0]
    echo "${res[@]}"
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
    local fmt_index=$((RANDOM % ${#fmts[@]}))
    echo "${fmts[$fmt_index]}"
}

# Return the number of songs of a given format
nsongs() {
    local fmt="$1"
    wc -l "$CMP_CONFIG_PATH/$fmt" | cut -f1 -d' '
}

# Return command line to play the given format
# TODO: replace regex match by is_in
fmt2cmd() {
    local fmt="$1"
    if [[ -n ${M1_FMTS[@]} && ${M1_FMTS[@]} =~ $fmt ]]; then
        echo "\"$M1_PRG_PATH\" -m0 -n -v5"
    elif [[ -n ${SIDPLAY2_FMTS[@]} && ${SIDPLAY2_FMTS[@]} =~ $fmt ]]; then
        echo "sidplay2"
    elif [[ -n ${XMP_FMTS[@]} && ${XMP_FMTS[@]} =~ $fmt ]]; then
        echo "xmp -l"
    elif [[ -n ${UADE_FMTS[@]} && ${UADE_FMTS[@]} =~ $fmt ]]; then
        echo "uade123.sh"
    elif [[ -n ${SC68_FMTS[@]} && ${SC68_FMTS[@]} =~ $fmt ]]; then
        echo "$PRG_DIR/sc68.sh"
    elif [[ -n ${AYLET_FMTS[@]} && ${AYLET_FMTS[@]} =~ $fmt ]]; then
        echo "aylet -A 0"
    elif [[ -n ${AUDACIOUS_FMTS[@]} && ${AUDACIOUS_FMTS[@]} =~ $fmt ]]; then
        echo "audacious -H"
    elif [[ -n ${ASAP_FMTS[@]} && ${ASAP_FMTS[@]} =~ $fmt ]]; then
        echo "asap.sh"
    elif [[ -n ${MIDI_FMTS[@]} && ${MIDI_FMTS[@]} =~ $fmt ]]; then
        echo "timidity --l"
    elif [[ -n ${VGMPLAY_FMTS[@]} && ${VGMPLAY_FMTS[@]} =~ $fmt ]]; then
        echo "$PRG_DIR/vgmplay.sh"
    else
        fatalError "Format $fmt is not supported"
    fi
}

# Given a file with song path, filter the songs containing the strings
# given in subsequent arguments, if any.
filter_songs() {
    local songs="$1"
    shift
    local str="$1"
    if [[ -n "$str" ]]; then
        grep "$str" "$songs"
        shift
        local str="$1"
        # Only do the recursive call if the next argument is not empty
        if [[ -n "$str" ]]; then
            filter_songs "$songs" "$@"
        fi
    else
        cat "$songs"
    fi
}

# Given the format return the filepath where the songs of that format
# are stored.
fmt_path() {
    local fmt="$1"
    local songs="$CMP_CONFIG_PATH/$fmt"
    echo "$songs"
}

# Random select a song of the given format
select_song() {
    local fmt="$1"
    local songs="$(fmt_path "$fmt")"
    shift
    local song="$(filter_songs "$songs" "$@" | shuf | head -n1)"
    case "$fmt" in
        "m1")
            echo "$song" | cut -d: -f1
            ;;
        *)
            echo "$song"
    esac
}

# List all supported formats
list_fmts() {
    echo "m1:"
    for fmt in ${M1_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "sidplay2:"
    for fmt in ${SIDPLAY2_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "xmp:"
    for fmt in ${XMP_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "uade:"
    for fmt in ${UADE_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "sc68:"
    for fmt in ${SC68_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "aylet:"
    for fmt in ${AYLET_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "audacious:"
    for fmt in ${AUDACIOUS_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "asap:"
    for fmt in ${ASAP_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "timidity:"
    for fmt in ${MIDI_FMTS[@]}; do echo -e "\t$fmt"; done
    echo "vgmplay:"
    for fmt in ${VGMPLAY_FMTS[@]}; do echo -e "\t$fmt"; done
}

# Given a list of strings, the first one representing an element, the
# others representing a list of strings return T if the string belongs
# to the list, F otherwise.
is_in() {
    local el="$1"
    shift
    for w in "$@"; do
        if [[ "$el" == "$w" ]]; then
            echo "T"
            return
        fi
    done
    echo "F"
    return
}

# Given a list of strings and formats only retain the formats
filter_fmts() {
    local fmts=()
    for el in "$@"; do
        if [[ $(is_in "$el" ${ALL_FMTS[@]}) == T ]]; then
            fmts+=("$el")
        fi
    done
    echo "${fmts[@]}"
}

# Given a list of strings and format only retain the strings and fill
# global array variable strs
filter_strs() {
    strs=()
    for el in "$@"; do
        if [[ $(is_in "$el" ${ALL_FMTS[@]}) == F ]]; then
            strs+=("$el")
        fi
    done
}

########
# Main #
########

# Create config path
mkdir $CMP_CONFIG_PATH &> /dev/null

# Copy m1 xml file to current directory, otherwise m1 doesn't work, I
# don't know why.
cp $M1_XML_PATH . &> /dev/null
cp $M1_INI_PATH . &> /dev/null

ALL_FMTS=(${M1_FMTS[@]} ${SIDPLAY2_FMTS[@]} ${XMP_FMTS[@]} ${UADE_FMTS[@]} ${SC68_FMTS[@]} ${AYLET_FMTS[@]} ${AUDACIOUS_FMTS[@]} ${ASAP_FMTS[@]} ${MIDI_FMTS[@]} ${VGMPLAY_FMTS[@]})

# First time or user update
if [[ -z $(get_existing_fmts) || "$1" == update ]]; then
    shift
    if [[ $# == 0 ]]; then
        update ${ALL_FMTS[@]}
    else
        update $(filter_fmts "$@")
    fi
    exit 0
fi

# List all supported formats
if [[ "$1" == list ]]; then
    list_fmts
    exit 0
fi

# Pick up the chiptune format
fmts=($(filter_fmts "$@"))
fmt="$(select_fmt ${fmts[@]})"
infoEcho "Select $fmt format ($(nsongs $fmt) songs)"

# Fill array variable strs with strings
filter_strs "$@"
if [[ ${#strs[@]} != 0 ]]; then
    n_filtered=$(filter_songs "$(fmt_path "$fmt")" "${strs[@]}" | wc -l)
    infoEcho "Filter according to strings: ($n_filtered songs)"
    for str in "${strs[@]}"; do
        echo -e "\t$str"
    done
fi

# Pick up the song to play
song="$(select_song "$fmt" "${strs[@]}")"
if [[ -n "$song" ]]; then
    infoEcho "Select $song"
else
    infoEcho "No selected song"
    exit 1
fi

# Build the command line and play the song
cmd="$(fmt2cmd "$fmt") \"$song\""
infoEcho "$cmd"
eval "$cmd"
