
# Entry makefile for developing this project.

include ../flexo.mk

$(call flexo.add,git)
git.PATH := $(abspath ..)

.PHONY: all
all: git.status

git.status:
	git -C $(git.PATH) status

git.stage:
	git -C $(git.PATH) add .

git.commit:
	git -C $(git.PATH) commit