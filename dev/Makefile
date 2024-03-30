
# Entry makefile for developing this project.

include ../flexo.mk

$(call flexo.add,git)
git.PATH := $(abspath ..)

$(call flexo.add,formatter)

.PHONY: all
all: git.status
