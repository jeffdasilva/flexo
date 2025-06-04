
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
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(uv.exe))),\
		@echo "Installing uv..."; curl -LsSf https://astral.sh/uv/install.sh | sh)


uv.tools.packages = \
	ruff \
	mypy \
	pytest

#uv.tools.packages += \
#	pytest-asyncio \
#	$(if $(call flexo.true,$(pytest.testmon.enabled)),pytest-testmon)

uv.install.tools.targets = $(patsubst %,uv.install.tools-%,$(uv.tools.packages))

$(uv.install.tools.targets): uv.install.tools-%: uv.install
	$(uv.exe) tool install $*


.PHONY: uv.install.tools
uv.install.tools: $(uv.install.tools.targets)

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


###############################################################################

format: uv.format

.PHONY: uv.format
uv.format: uv.ruff.format

.PHONY: uv.ruff.format
uv.ruff.format:
	$(uvx.exe) ruff format

.PHONY: ruff
ruff: uv.ruff

.PHONY: uv.ruff
uv.ruff: uv.ruff.format

###############################################################################


###############################################################################

check: uv.check

.PHONY: uv.check
uv.check: uv.ruff.check uv.mypy.check

.PHONY: uv.ruff.check
uv.ruff.check:
	$(uvx.exe) ruff check

.PHONY: uv.mypy.check
uv.mypy.check:
	$(uvx.exe) mypy --strict --ignore-missing-imports --show-error-code-links .

.PHONY: mypy
mypy: uv.mypy

.PHONY: uv.mypy
uv.mypy: uv.mypy.check

###############################################################################


###############################################################################

test: uv.pytest

.PHONY: uv.pytest
uv.pytest:
	$(uvx.exe) pytest -v -s $(if $(call flexo.true,$(pytest.testmon.enabled)),--testmon)

.PHONY: pytest
pytest: uv.pytest

###############################################################################