#!/usr/bin/make -f
#
# Makefile for NES game
# Copyright 2011-2014 Damian Yerrick
# (Edited by Pubby)
#
# Copying and distribution of this file, with or without
# modification, are permitted in any medium without royalty
# provided the copyright notice and this notice are preserved.
# This file is offered as-is, without any warranty.
#

# These are used in the title of the NES program
title := ralph4
version := 0.01

# Space-separated list of assembly language files that make up the
# PRG ROM.  If it gets too long for one line, you can add a backslash
# (the \ character) at the end of the line and continue on the next.
objlist := nrom init main bg player \
levels enemies trig levelload globals palette gamepad sprites famitone2 \
ralph4_music ralph4_sfx

AS65 := ca65
LD65 := ld65
objdir := obj/nes
srcdir := src
imgdir := tilesets

EMU := fceux
#EMU := wine fceux/fceux.exe

TEXT2DATA := wine tools/text2data.exe
NSF2DATA := wine tools/nsf2data.exe

.PHONY: all run clean

all: $(title).nes 

run: $(title).nes
	$(EMU) $<

clean:
	-rm $(objdir)/*.o $(objdir)/*.s $(objdir)/*.chr

# Rules for PRG ROM

objlistntsc := $(foreach o,$(objlist),$(objdir)/$(o).o)

map.txt $(title).nes: nrom128.cfg $(objlistntsc)
	$(LD65) -o $(title).nes -m map.txt -C $^

$(objdir)/%.o: $(srcdir)/%.s $(srcdir)/nes.inc $(srcdir)/globals.inc
	$(AS65) $(CFLAGS65) $< -o $@

$(objdir)/%.o: $(objdir)/%.s
	$(AS65) $(CFLAGS65) $< -o $@

# Files that depend on .incbin'd files
$(objdir)/main.o: $(objdir)/bg.chr $(objdir)/sprites16.chr

# Rules for CHR ROM

$(title).chr: $(objdir)/bg.chr $(objdir)/sprites16.chr
	cat $^ > $@

$(objdir)/%.chr: $(imgdir)/%.png
	tools/pilbmp2nes.py $< $@

$(objdir)/%16.chr: $(imgdir)/%.png
	tools/pilbmp2nes.py -H 16 $< $@

# music
$(srcdir)/ralph4_music.s: ralph4_music.txt
	$(TEXT2DATA) -ca65 $<
	echo ".export ralph4_music_music_data" > $@;
	cat ralph4_music.s >> $@

# sfx
$(srcdir)/ralph4_sfx.s: ralph4_sfx.nsf
	$(NSF2DATA) $< -ca65 
	echo ".export sounds" > $@;
	cat ralph4_sfx.s >> $@

# cpp
levelc: levelc.cpp
	 $(CXX) -std=c++14 $< -o $@

trigtablegen: trigtablegen.cpp
	 $(CXX) -std=c++14 $< -o $@

$(srcdir)/levels.s: levelc levels.txt
	./levelc levels.txt $@

$(srcdir)/trig.s: trigtablegen
	./trigtablegen $@
