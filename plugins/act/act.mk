

act.exe = $(abspath ./bin/act)

act.installed = $(or $(call have_exe,$(act.exe)),$(wildcard $(act.exe)))

####################################################################
# Locally run github actions with act

install: act.install

.PHONY: act.install
act.install:
ifeq ($(act.installed),)
	@echo "act requires Docker to be installed and running. So let's check if Docker is installed and working..."
	docker version
	docker info
	docker run hello-world
	@echo "Installing act..."
	curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
endif

.PHONY: act
act: $(if $(act.installed),,act.install)
	$(act.exe)
####################################################################