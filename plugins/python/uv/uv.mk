
###############################################################################
# Variables

uv.exe := uv
uv.uvx.exe := uvx

uv.run.entrypoint ?= $(firstword $(wildcard main.py) $(wildcard *main.py))

###############################################################################

install: uv.install uv.install.tools

# https://github.com/astral-sh/uv
.PHONY: uv.install
uv.install:
	$(if $(or $(filter install $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(uv.exe))),\
		@echo "Installing uv..."; curl -LsSf https://astral.sh/uv/install.sh | sh)

.PHONY: uv.install.tools
uv.install.tools: uv.install
	$(uv.exe) tool install ruff
	$(uv.exe) tool install mypy
	$(uv.exe) tool install pytest

###############################################################################


###############################################################################

init: uv.init uv.lock

.PHONY: uv.init
uv.init:
	$(uv.exe) init

ifeq ($(filter uv.lock,$(MAKECMDGOALS)),uv.lock)
.PHONY: uv.lock
endif
uv.lock: $(if $(wildcard pyproject.toml),pyproject.toml,uv.init)
	$(uv.exe) lock

.PHONY: uv.sync
uv.sync:
	$(uv.exe) sync

.PHONY: uv.venv
uv.venv:
	$(uv.exe) venv

###############################################################################


###############################################################################

run: uv.run
.PHONY: uv.run

uv.run: $(uv.run.entrypoint)
	$(uv.exe) run $<

###############################################################################





###############################################################################

clean: uv.clean

.PHONY: uv.clean
uv.clean:
	@find . -name __pycache__ -type d -exec rm -rvf {} +

###############################################################################
