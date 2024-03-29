###############################################################################
# Flexo - A flexible and extensible platform for enhancing your Makefiles
#
# flexo.mk - The main entry makefile fragement
#
# Code licensed under MIT 2024 (c) Jeff DaSilva
###############################################################################

FLEXO.ROOT_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
FLEXO.ROOT_DIR := $(patsubst %/,%,$(dir $(FLEXO.ROOT_MAKEFILE)))
FLEXO.PLUGINS_DIR := $(FLEXO.ROOT_DIR)/plugins

FLEXO.MAKECMDGOALS := $(filter flexo.%,$(MAKECMDGOALS))

###############################################################################
# Stuff that gnu make should enable by default (in my opinion) 
.SUFFIXES:
.DELETE_ON_ERROR:
.SECONDEXPANSION:

SHELL := /bin/bash

override empty :=
override SPACE := $(empty) $(empty)
COMMA := ,
###############################################################################

ifeq ($(FLEXO.DEBUG),1)
define flexo.debug
$(info FLEXO_DEBUG: $(1))
endef
endif

ifneq ($(filter flexo.update,$(FLEXO.MAKECMDGOALS)),)
.PHONY: flexo.update
flexo.update:
	@echo "Updating flexo..."
	@cd $(FLEXO.ROOT_DIR) && git pull
endif

FLEXO.PLUGINS := $(patsubst $(FLEXO.PLUGINS_DIR)/%/inc.mk,%,$(wildcard $(FLEXO.PLUGINS_DIR)/*/inc.mk))
$(call flexo.debug,Available Plugins: $(FLEXO.PLUGINS))
