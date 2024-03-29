###############################################################################
# Flexo - A flexible and extensible platform for enhancing your Makefiles
#
# flexo.mk - The main entry makefile fragement
#
# Code licensed under MIT 2024 (c) Jeff DaSilva
###############################################################################

ifneq ($(FLEXO.ROOT_DIR),)
$(error ERROR: FLEXO.ROOT_DIR already defined. This makefile should be included only once)
endif

FLEXO.ROOT_MAKEFILE := $(abspath $(subst \,/,$(lastword $(MAKEFILE_LIST))))
FLEXO.ROOT_DIR := $(patsubst %/,%,$(dir $(FLEXO.ROOT_MAKEFILE)))
FLEXO.PLUGINS_DIR += $(FLEXO.ROOT_DIR)/plugins

FLEXO.MAKECMDGOALS := $(filter flexo.%,$(MAKECMDGOALS))
FLEXO.VARIABLES_INIT := $(.VARIABLES)

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

FLEXO.VERBOSE ?= $(VERBOSE)
QUIET = $(if $(call flexo.true,$(FLEXO.VERBOSE)),,@)

ifneq ($(filter flexo.update,$(FLEXO.MAKECMDGOALS)),)
.PHONY: flexo.update
flexo.update:
	@echo "Updating Flexo..."
	$(QUIET)git -C $(FLEXO.ROOT_DIR) pull
endif

define flexo.discover
$(strip \
$(if $1,,$(call flexo.error,ARG1 [plugin_dir] not specified for function $0))
$(foreach plugin_dir,$1,\
	$(eval plugin_dir_abs = $(abspath $(plugin_dir)))

	$(foreach plugin_mk,$(wildcard $(plugin_dir_abs)/*/flexo.mk),\
    	$(eval plugin_name = $(patsubst $(plugin_dir_abs)/%/flexo.mk,%,$(plugin_mk)))
	  
	  	$(if $(filter $(plugin_name),$(FLEXO.PLUGINS)),\
	    	$(call flexo.warning,Plugin $(plugin_name) already loaded. Skipping...),\
	    	$(call flexo.debug,Discover Plugin: $(plugin_name))\
			  $(eval FLEXO.PLUGINS += $(plugin_name))\
	  		  $(eval $(plugin_name).flexo.mk := $(abspath $(plugin_mk)))\
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
