
git.exe ?= git

git.toplevel = $(shell $(git.exe) rev-parse --show-toplevel 2>/dev/null)

git.cmd ?= $(git.exe)$(if $(git.path), -C $(git.path))
git.cmd_toplevel ?= $(git.exe)$(if $(git.toplevel), -C $(git.toplevel))

git._ls-files = $(shell $(git.cmd) ls-files)
git.ls-files = $(if $(git.path),$(addprefix $(git.path)/,$(git._ls-files)),$(git._ls-files))

git.ALIAS_COMMANDS += status pull push commit diff ls-files
git.ALIAS_TARGETS += $(patsubst %,git.%, $(git.ALIAS_COMMANDS))

.PHONY: $(git.ALIAS_TARGETS)
$(git.ALIAS_TARGETS): git.%:
	$(git.cmd) $*

.PHONY: git.stage
git.stage:
	$(git.cmd) add .

.PHONY: git.stage-diff
git.stage-diff:
	$(git.cmd) diff --cached

.PHONY: git.reset-to-last-commit
git.reset-to-last-commit:
	$(git.cmd) reset HEAD .

.PHONY: git.lazy-commit git.lazy
git.lazy-commit git.lazy:
	$(if $(COMMIT_MSG),,$(info INFO: If you want lazier do: '$(MAKE) $@ COMMIT_MSG="..."'))
	$(git.cmd) add .
	$(git.cmd) commit $(if $(COMMIT_MSG),-am "$(COMMIT_MSG)",-a)
	$(git.cmd) push

.PHONY: sync
sync: git.pull

.PHONY: diff
diff: git.diff

.PHONY: revert
revert: git.reset-to-last-commit