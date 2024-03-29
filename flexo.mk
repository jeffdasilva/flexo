###############################################################################
# Flexo - A flexible and extensible platform for enhancing your Makefiles
#
# flexo.mk - The main entry makefile fragement
#
# Code licensed under MIT 2024 (c) Jeff DaSilva
###############################################################################

FLEXO.ROOT_MAKEFILE := $(lastword $(MAKEFILE_LIST))
FLEXO.ROOT_DIR := $(dir $(FLEXO.ROOT_MAKEFILE))

FLEXO.MAKECMDGOALS := $(filter flexo.%,$(MAKECMDGOALS))

###############################################################################
# Stuff that gnu make should enable by default (in my opinion) 
.SUFFIXES:
.DELETE_ON_ERROR:
.SECONDEXPANSION:

SHELL := /bin/bash

override empty :=
override SPACE := $(empty) $(empty)
###############################################################################


ifneq ($(filter flexo.update,$(FLEXO.MAKECMDGOALS)),)
.PHONY: flexo.update
flexo.update:
	@echo "Updating flexo..."
	@cd $(FLEXO.ROOT_DIR) && git pull
endif
