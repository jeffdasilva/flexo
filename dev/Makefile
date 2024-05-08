
# Entry makefile for developing this project.

include ../flexo.mk

$(call flexo.add,git)
git.path = $(git.toplevel)

$(call flexo.add,formatter)
$(call flexo.add,help)

$(call flexo.add,clean)
clean.directories += work

all.help = Runs 'git status'
.PHONY: all
all: git.status

$(flexo.generate)