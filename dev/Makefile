
# Entry makefile for developing this project.

include ../flexo.mk

$(call flexo.add,git)
git.path = $(git.toplevel)

$(call flexo.add,formatter)
$(call flexo.add,help)

all.help = Runs 'git status'
.PHONY: all
all: git.status

$(flexo.generate)