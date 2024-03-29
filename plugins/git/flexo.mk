
git.exe ?= git
git.cmd ?= $(git.exe) $(if $(git.PATH),-C $(git.PATH))

.PHONY: git.status
git.status:
	$(git.cmd) status

.PHONY: git.stage
git.stage:
	$(git.cmd) add .

.PHONY: git.commit
git.commit:
	$(git.cmd) commit

.PHONY: git.push
git.push:
	$(git.cmd) push