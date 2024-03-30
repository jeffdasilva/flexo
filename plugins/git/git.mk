
git.exe ?= git
git.cmd ?= $(git.exe) $(if $(git.PATH),-C $(git.PATH))

.PHONY: sync
sync: git.pull

.PHONY: diff
diff: git.diff

git.ALIAS_COMMANDS += status pull push commit diff
git.ALIAS_TARGETS += $(patsubst %,git.%, $(git.ALIAS_COMMANDS))

.PHONY: $(git.ALIAS_TARGETS)
$(git.ALIAS_TARGETS): git.%:
	$(git.cmd) $*

.PHONY: git.stage
git.stage:
	$(git.cmd) add .
