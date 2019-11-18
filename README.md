# Chiptune Meta Player

## Overview

This program have been written with in mind to facilitate to listen to
chiptune music while working. It selects a random chiptune file
amongst the ones present on your computer, and play it in loop till
explicit interrupted by the user, in order to minimize interferences
with the user's thoughts - by avoiding music changes. If you find
yourself listening to the same song in loop for 20 minutes, your are
using this program for the intended purpose. ;-)

## Requirements

1. sidplay2, for playing SID
2. xmp, for playing MOD and such 
3. m1, for playing MAME rips
4. sc68, for playing sc68. Download and compile sc68-2.2.1
5. uade, http://zakalwe.fi/uade/ you only need to compile uade123
```
./configure
make -j5 uade123 && sudo make install
```
6. timidity, http://timidity.sourceforge.net/
7. vgmplay, https://github.com/vgmrips/vgmplay. Also to loop create a config folder
```
mkdir ~/.config/vgmplay/
```
copy the default init file there
```
cp /usr/local/share/vgmplay/vgmplay.ini ~/.config/vgmplay
```
and assign `MaxLoops` and `MaxLoopsCMF` to `0xff`.

## Usage

The first time chiptune-meta-player.sh is run it will create a
database of all chiptune files under `~/Music` and its subfolders. The
second time you may run it with one or more formats in arguments. For
instance

```bash
./chiptune-meta-player.sh ahx sc68
```

will randomly select a song from the database with format ahx or sc68
and play it with the adequate player. In no format is provided it will
select one randomly amongst the supported ones.

If you want to play a sequence of songs you may wrap this program in a
loop

```bash
for i in {1..20}; do ./chiptune-meta-player.sh ahx sc68; done
```

or use `chiptune-meta-player-loop.sh` which does that for you. In that
case the first argument is the number of loops you wish to execute,
and the following arguments are directly passed to
`chiptune-meta-player.sh`. For instance the following is equivalent to
the for loop above

```bash
./chiptune-meta-player-loop.sh 20 ahx sc68
```

If some files have changed on your disk and you wish to update again
you may run

```bash
./chiptune-meta-player.sh update
```

If you wish to update only some formats, append then after
`update`. For instance the following will only update `mod` and `it`
files

```bash
./chiptune-meta-player.sh update mod it
```

## Supported formats

- 669
- ahx
- amc
- amf
- amm
- aon
- ast
- ay
- bss
- cm
- cus
- dat
- digi
- dl
- dm
- dmu
- dp
- dum
- dw
- dz
- emod
- ems
- far
- fnk
- fred
- gdm
- gmc
- hip
- hip7
- hipc
- imf
- ims
- is
- is20
- it
- jam
- jd
- jmf
- kh
- liq
- lme
- m1
- ma
- mc
- md
- mgt
- mid
- mmd0
- mmd1
- mmd2
- mmd3
- mmdc
- mod
- mok
- mso
- mtm
- ntp
- okta
- pap
- ps
- psf
- psm
- pt
- ptm
- puma
- pvp
- rh
- rho
- riff
- rtm
- s3m
- sas
- sb
- sc
- sc68
- scn
- scr
- scumm
- sfx
- sg
- sid
- smod
- sndh
- snk
- ss
- st26
- stm
- sun
- syn
- synmod
- tf
- thm
- ult
- vgm
- vgz
- wb
- xm
- ymst

## Author

Nil Geisweiller
