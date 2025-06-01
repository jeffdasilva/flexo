
git.exe ?= git

git.toplevel = $(shell $(git.exe) rev-parse --show-toplevel 2>/dev/null)

git.cmd ?= $(git.exe)$(if $(git.path), -C $(git.path))
git.cmd_toplevel ?= $(git.exe)$(if $(git.toplevel), -C $(git.toplevel))
git.have_dot_git = $(if $(wildcard $(if $(git.toplevel),$(git.toplevel)/.git,.git)),TRUE)

git._ls-files = $(shell $(git.cmd) ls-files)
git.ls-files = $(if $(git.have_dot_git),$(if $(git.path),$(addprefix $(git.path)/,$(git._ls-files)),$(git._ls-files)))

git.ALIAS_COMMANDS += $(if $(git.have_dot_git),status pull push commit diff ls-files,init)
git.ALIAS_TARGETS += $(patsubst %,git.%, $(git.ALIAS_COMMANDS))

.PHONY: $(git.ALIAS_TARGETS)
$(git.ALIAS_TARGETS): git.%:
	$(git.cmd) $*

.PHONY: git.stage
git.stage:
	$(git.cmd) add .

.PHONY: git.unstage git.restore
git.unstage git.restore:
	$(git.cmd) restore .

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

.PHONY: git.info
git.info:
	@echo ======================================
	$(git.cmd) remote -v
	@echo ======================================
	$(git.cmd) branch --list -r
	@echo ======================================
	$(git.cmd) log --oneline --graph --decorate --all -3
	@echo ======================================
	$(git.cmd) status
	@echo ======================================


.PHONY: sync
sync: git.pull

.PHONY: diff
diff: git.diff

.PHONY: revert
revert: git.reset-to-last-commit git.unstage

init: $(filter git.init,$(git.ALIAS_TARGETS))

init: git.init.gitignore

git.gitignore_file ?= $(if $(git.toplevel),$(git.toplevel)/).gitignore

# https://github.com/github/gitignore
git.gitignore.template_url.cplusplus ?= https://raw.githubusercontent.com/github/gitignore/main/C%2B%2B.gitignore
git.gitignore.template_url.python ?= https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore
git.gitignore.template_url.vscode ?= https://raw.githubusercontent.com/github/gitignore/main/Global/VisualStudioCode.gitignore

git.gitignore.template_url ?= $(strip $(firstword \
	$(foreach template_url,$(patsubst git.gitignore.template_url.%,%,$(filter git.gitignore.template_url.%,$(.VARIABLES))),\
		$(if $($(template_url).enabled),$(git.gitignore.template_url.$(template_url))) \
	) \
))

git.init.gitignore:
	$(if $(wildcard $(git.gitignore_file)),,\
		$(if $(git.gitignore.template_url),\
			wget $(git.gitignore.template_url) -O $(git.gitignore_file)))


install: git.install

.PHONY: git.install
git.install:
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(git.exe))),sudo apt install -y git)