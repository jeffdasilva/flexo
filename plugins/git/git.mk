
git.exe ?= git
git.cmd ?= $(git.exe) $(if $(git.PATH),-C $(git.PATH))

git._ls-files = $(shell $(git.cmd) ls-files)
git.ls-files = $(if $(git.PATH),$(addprefix $(git.PATH)/,$(git._ls-files)),$(git._ls-files))

.PHONY: sync
sync: git.pull

.PHONY: diff
diff: git.diff

git.ALIAS_COMMANDS += status pull push commit diff ls-files
git.ALIAS_TARGETS += $(patsubst %,git.%, $(git.ALIAS_COMMANDS))

.PHONY: $(git.ALIAS_TARGETS)
$(git.ALIAS_TARGETS): git.%:
	$(git.cmd) $*

.PHONY: git.stage
git.stage:
	$(git.cmd) add .
