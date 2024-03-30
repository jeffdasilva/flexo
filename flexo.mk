###############################################################################
# Flexo - A flexible and extensible platform for enhancing your Makefiles
#
# flexo.mk - The main entry makefile fragement
#
# Code licensed under MIT 2024 (c) Jeff DaSilva
#
# I highly recommend never touching this file once it's all working.
#   => VERY VERY FRAGILE Code in here!
#
###############################################################################

ifneq ($(flexo.root_dir),)
$(error ERROR: flexo.root_dir already defined. This makefile should be included only once)
endif

flexo.root.mk := $(abspath $(subst \,/,$(lastword $(MAKEFILE_LIST))))
flexo.root_dir := $(patsubst %/,%,$(dir $(flexo.root.mk)))

############################
#
# Allowed global scoped variables
# FLEXO.DEBUG FLEXO.PLUGINS FLEXO.VERBOSE
#
# "Static" scoped variables that will be undefined befere this makefile exists
FLEXO.PLUGINS_DIR := $(flexo.root_dir)/plugins
FLEXO.MAKECMDGOALS := $(filter flexo.%,$(MAKECMDGOALS))
FLEXO.VARIABLES_INIT := $(.VARIABLES)
############################

###############################################################################
# Stuff that gnu make should enable by default (in my opinion)
.SUFFIXES:
.DELETE_ON_ERROR:
.SECONDEXPANSION:

SHELL := /bin/bash

override empty :=
override SPACE := $(empty) $(empty)
COMMA := ,

define tolower
$(subst A,a,$(subst B,b,$(subst C,c,$(subst D,d,$(subst E,e,$(subst F,f,$(subst G,g,$(subst H,h,$(subst I,i,$(subst J,j,$(subst K,k,$(subst L,l,$(subst M,m,$(subst N,n,$(subst O,o,$(subst P,p,$(subst Q,q,$(subst R,r,$(subst S,s,$(subst T,t,$(subst U,u,$(subst V,v,$(subst W,w,$(subst X,x,$(subst Y,y,$(subst Z,z,$1))))))))))))))))))))))))))
endef

define toupper
$(subst a,A,$(subst b,B,$(subst c,C,$(subst d,D,$(subst e,E,$(subst f,F,$(subst g,G,$(subst h,H,$(subst i,I,$(subst j,J,$(subst k,K,$(subst l,L,$(subst m,M,$(subst n,N,$(subst o,O,$(subst p,P,$(subst q,Q,$(subst r,R,$(subst s,S,$(subst t,T,$(subst u,U,$(subst v,V,$(subst w,W,$(subst x,X,$(subst y,Y,$(subst z,Z,$1))))))))))))))))))))))))))
endef

# If you don't already have a default target then "all" will be the default target
.PHONY: all
all:

###############################################################################

define flexo.true
$(if $(filter-out 0 n no f false disable,$(call tolower,$1)),T,)
endef

define flexo.false
$(if $(call flexo.true,$1),,T)
endef

define flexo.debug
$(if $(call flexo.true,$(FLEXO.DEBUG)),$(info FLEXO_DEBUG: $(1)))
endef

define flexo.warning
$(warning FLEXO_WARNING: $(1))
endef

define flexo.error
$(error FLEXO_ERROR: $(1))
endef

define flexo.debug.call
$(call flexo.debug,::$0($(if $1,$1)$(if $2,$(COMMA)$2))::)
endef

FLEXO.VERBOSE ?= $(VERBOSE)
QUIET = $(if $(call flexo.true,$(FLEXO.VERBOSE)),,@)

ifneq ($(filter flexo.update,$(FLEXO.MAKECMDGOALS)),)
.PHONY: flexo.update
flexo.update:
	@echo "Updating Flexo..."
	$(QUIET)git -C $(flexo.root_dir) pull
endif

# arg 1: plugin name
# arg 2: plugin makefile
define flexo.discover_plugin
$(strip \
$(flexo.debug.call)
$(if $1,,$(call flexo.error,ARG1 [plugin_name] not specified for function $0))
$(if $2,,$(call flexo.error,ARG2 [plugin_mk] not specified for function $0))
$(eval plugin_name = $1)
$(eval plugin_mk = $2)
$(if $(filter $(plugin_name),$(FLEXO.PLUGINS)),\
	$(call flexo.debug,Plugin $(plugin_name) already loaded. Skipping...),\
	$(call flexo.debug,Discover Plugin: $(plugin_name))\
		$(eval FLEXO.PLUGINS += $(plugin_name))\
		$(eval flexo.$(plugin_name).mk := $(abspath $(plugin_mk)))\
))
endef

# arg 1: plugin directory
define flexo.discover
$(strip \
$(flexo.debug.call)
$(if $1,,$(call flexo.error,ARG1 [plugin_dir] not specified for function $0))
$(foreach plugin_dir,$1,\
	$(eval plugin_dir_abs = $(abspath $(plugin_dir)))
	$(foreach plugin_subdir,$(patsubst $(plugin_dir)/%,%,$(wildcard $(plugin_dir)/*)),\
		$(foreach plugin_mk,$(wildcard $(plugin_dir_abs)/$(plugin_subdir)/flexo.mk) $(wildcard $(plugin_dir_abs)/$(plugin_subdir)/$(plugin_subdir).mk),\
			$(eval plugin_name = $(plugin_subdir))
			$(call flexo.discover_plugin,$(plugin_name),$(plugin_mk))
		)
	)
))
endef

ifneq ($(FLEXO.PLUGINS),)
$(call flexo.error,FLEXO.PLUGINS already set [$(FLEXO.PLUGINS)]. This is not expected)
endif
FLEXO.PLUGINS :=
$(call flexo.discover,$(FLEXO.PLUGINS_DIR))

$(call flexo.debug,Available Plugins: $(FLEXO.PLUGINS))

define flexo.assert_is_plugin
$(strip \
$(if $(filter $1,$(FLEXO.PLUGINS)),,\
	$(call flexo.error,Plugin '$1' not found. Available plugins: $(FLEXO.PLUGINS)))
)
endef

define flexo.makefile
$(strip \
$(if $1,,$(call flexo.error,ARG1 [plugin_name] not specified for function $0))
$(flexo.assert_is_plugin,$1)
$(if $(flexo.$1.mk),,$(call flexo.error,Plugin '$1' does not have a makefile defined))
$(if $(wildcard $(flexo.$1.mk)),,$(call flexo.error,Plugin '$1' makefile not found: $(flexo.$1.mk)))
$(flexo.$1.mk)
)
endef

# need to cheat and preload the builtins stack plugin because it is used by the plugin loader
include $(flexo.root_dir)/plugins/builtins/flexo.mk

# ToDo: Be sure not to load it twice
define flexo.add
$(strip \
$(flexo.debug.call)
$(if $1,,$(call flexo.error,ARG1 [plugin_name] not specified for function $0))
$(flexo.assert_is_plugin,$1)
$(eval FLEXO.VARIABLES.ORIG := $(.VARIABLES))
$(eval include $(call flexo.makefile,$1))
$(if $(filter-out FLEXO.VARIABLES.ORIG flexo.% $(1).% $(FLEXO.VARIABLES.ORIG),$(.VARIABLES)),\
	$(call flexo.error,Flexo Plugin '$(1)' defined illegal variables: $(filter-out FLEXO.VARIABLES.ORIG flexo.% $(1).% $(FLEXO.VARIABLES.ORIG),$(.VARIABLES))),\
	$(call flexo.debug,Flexo Plugin '$(1)' loaded successfully)\
)
$(eval undefine FLEXO.VARIABLES.ORIG)
)
endef

$(call flexo.add,builtins)

# move this into builtins if you can
$(call flexo.add,stack)


############################
# unset the "Static" scope variables
undefine FLEXO.PLUGINS_DIR
undefine FLEXO.MAKECMDGOALS
undefine FLEXO.VARIABLES_INIT

FLEXO.ILLEGAL_SCOPE_VARIALBES := $(filter-out FLEXO.DEBUG FLEXO.PLUGINS FLEXO.VERBOSE,$(filter FLEXO.%,$(.VARIABLES)))
ifneq ($(FLEXO.ILLEGAL_SCOPE_VARIALBES),)
$(call flexo.error,Illegal variables defined in global scope: $(FLEXO.ILLEGAL_SCOPE_VARIALBES))
endif
undefine FLEXO.ILLEGAL_SCOPE_VARIALBES
############################
