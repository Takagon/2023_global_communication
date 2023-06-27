# TeX Makefile
# Copyright (c) 2016 Tiryoh <tiryoh@gmail.com>
# 
# This Makefile is released under the MIT License.
# https://tiryoh.mit-license.org

.SUFFIXES: .tex .eps .dvi .pdf
.PRECIOUS: %.dvi
.PHONY: all clean refresh

UNAME_S:=$(shell uname -s)
ifeq ($(UNAME_S),Darwin)
TEXPATH:=/Library/TeX/texbin/
endif
ifeq ($(UNAME_S),Linux)
TEXPATH:=/usr/bin/
endif
TEXBIN:=platex
DVIBIN:=dvipdfmx
BIBBIN:=pbibtex
TEXFLAGS:=--kanji=utf8 --shell-escape --halt-on-error --file-line-error --synctex=1
DVIFLAGS:=
SOURCE:=$(wildcard *.tex)
FILENAME:=$(patsubst %.tex,%,$(SOURCE))
TARGET:=$(SOURCE:.tex=.pdf)


# all:$(TARGET)
# all-pdf-ja:$(TARGET)
all-pdf-ja:pdf

pdf:refresh $(FILENAME).pdf

dvi:refresh $(FILENAME).dvi

.tex.dvi:
	cp $< $<.bak
	sed 's/。/．/g' $< > $<.tmp
	sed 's/、/，/g' $<.tmp >| $< && rm -r $<.tmp
	$(TEXPATH)$(TEXBIN) $(TEXFLAGS) $< || mv $<.bak $<
	# - [ -e $(patsubst %.tex,%.bbl,$<) ] && echo "hoge" || $(TEXPATH)$(BIBBIN) $(patsubst %.tex,%,$<) || mv $<.bak $<
	if [ -e $(patsubst %.tex,%.bbl,$<) ]; \
	then \
		echo "hoge" ; \
		echo $(patsubst %.tex,%.bbl,$<); \
	else \
		echo "foo" ; \
		$(TEXPATH)$(BIBBIN) $(patsubst %.tex,%,$<) || mv $<.bak $< ; \
		sed 's/item\[.*\]/item/g' $(patsubst %.tex,%.bbl,$<) > $(patsubst %.tex,%.bbl,$<).tmp ; \
		sed 's/y}{.*}/y}{1}/g' $(patsubst %.tex,%.bbl,$<).tmp >| $(patsubst %.tex,%.bbl,$<) && rm -r $(patsubst %.tex,%.bbl,$<).tmp ; \
	fi;
	$(TEXPATH)$(TEXBIN) $(TEXFLAGS) $< || mv $<.bak $<
	$(TEXPATH)$(TEXBIN) $(TEXFLAGS) $<
	mv $<.bak $<

ifeq ($(UNAME_S),Darwin)
.dvi.pdf:
	$(TEXPATH)$(DVIBIN) $<
	# open -a Preview.app ./$(TARGET)
endif

ifeq ($(UNAME_S),Linux)
.dvi.pdf:
	$(TEXPATH)$(DVIBIN) $<
	# evince ./$(TARGET)
endif

clean:
	- rm $(FILENAME).aux $(FILENAME).synctex.gz $(FILENAME).toc $(FILENAME).log $(FILENAME).fdb_latexmk $(FILENAME).fls $(FILENAME).dvi $(FILENAME).log $(FILENAME).bbl $(FILENAME).blg

distclean: clean
	- rm $(TARGET)

refresh:
	- rm $(FILENAME).dvi $(FILENAME).pdf

bib: dvi
	$(TEXPATH)$(BIBBIN) $(patsubst %.tex,%,$(FILENAME))
	sed 's/item\[.*\]/item/g' $(FILENAME).bbl > $(FILENAME).bbl.tmp
	sed 's/y}{.*}/y}{1}/g' $(FILENAME).bbl.tmp >| $(FILENAME).bbl && rm -r $(FILENAME).bbl.tmp
