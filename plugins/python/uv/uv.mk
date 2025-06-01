
###############################################################################
# Variables

uv.exe := uv
uv.uvx.exe := uvx


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
	uv init

ifeq ($(filter uv.lock,$(MAKECMDGOALS)),uv.lock)
.PHONY: uv.lock
endif
uv.lock: $(if $(wildcard pyproject.toml),pyproject.toml,uv.init)
	uv lock

.PHONY: uv.sync
uv.sync:
	uv sync

.PHONY: uv.venv
uv.venv:
	uv venv

###############################################################################


###############################################################################

clean: uv.clean

.PHONY: uv.clean
uv.clean:
	@find . -name __pycache__ -type d -exec rm -rvf {} +

###############################################################################
