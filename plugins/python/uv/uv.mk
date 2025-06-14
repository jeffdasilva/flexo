
###############################################################################
# Variables

uv.exe := uv
uv.uvx.exe := uvx

uv.run.entrypoint ?= $(firstword $(wildcard main.py) $(wildcard *main.py))
uv.project_config ?= pyproject.toml

###############################################################################

install: uv.install

#install: uv.install.tools

# https://github.com/astral-sh/uv
.PHONY: uv.install
uv.install:
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(uv.exe))),\
		@echo "Installing uv..."; curl -LsSf https://astral.sh/uv/install.sh | sh)


uv.tools.packages = \
	ruff \
	mypy

# I think these should be installed as normal python packages and not as uv tools.
#uv.tools.packages += \
#   pytest \
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

uv.clean.cache_dirs += \
	$(uv.pylint.cache_dir) \
	.mypy_cache \
	.pytest_cache \
	.ruff_cache

.PHONY: uv.clean
uv.clean:
	@find . -name __pycache__ -type d -exec rm -rvf {} +
	$(if $(wildcard $(uv.clean.cache_dirs)),rm -rf $(wildcard $(uv.clean.cache_dirs)))

###############################################################################


###############################################################################

format: uv.format

.PHONY: uv.format
uv.format: uv.ruff.format

.PHONY: uv.ruff.format
uv.ruff.format:
	$(uv.uvx.exe) ruff format

.PHONY: ruff
ruff: uv.ruff

.PHONY: uv.ruff
uv.ruff: uv.ruff.format

format: uv.isort.format

.PHONY: uv.isort.format
uv.isort.format:
	$(uv.uvx.exe) isort .

.PHONY: isort
isort: uv.isort

.PHONY: uv.isort
uv.isort: uv.isort.format

###############################################################################


###############################################################################

check: uv.check

.PHONY: uv.check
uv.check: uv.ruff.check uv.mypy.check

.PHONY: uv.ruff.check
uv.ruff.check:
	$(uv.uvx.exe) ruff check

uv.mypy.args += \
	$(if $(uv.project_config),--config-file=$(uv.project_config)) \
	--strict \
	--pretty \
	--ignore-missing-imports \
	--show-error-code-links

.PHONY: uv.mypy.check
uv.mypy.check: $(uv.project_config)
	$(uv.uvx.exe) mypy $(uv.mypy.args) .

.PHONY: mypy
mypy: uv.mypy

.PHONY: uv.mypy
uv.mypy: uv.mypy.check

.PHONY: uv.ty
uv.ty:
	$(uv.uvx.exe) ty check

.PHONY: ty
ty: uv.ty

###############################################################################

###############################################################################
# Linting

uv.pylint.cache_dir = .pylint_cache

.PHONY: lint
lint: uv.lint

.PHONY: uv.lint
uv.lint: uv.pylint

uv.pylint.targets = $(patsubst %,uv-pylint-%,$(pylint.files))

.PHONY: uv.pylint
uv.pylint: $(uv.pylint.targets)

uv.pylint.args += \
	$(pylint.args) \
	--logging-format-style=new \
	--output-format=colorized \
	--disable=import-error \
	--disable=logging-fstring-interpolation

.PHONY: $(uv.pylint.targets)
$(uv.pylint.targets): uv-pylint-%: $(uv.pylint.cache_dir)/%.pytest-check

$(uv.pylint.cache_dir)/%.pytest-check: % $(uv.project_config) | $$(@D)/.f
	$(uv.uvx.exe) pylint $(uv.pylint.args) $<
	@touch $@

.PRECIOUS: $(uv.pylint.cache_dir)/%.f
$(uv.pylint.cache_dir)/%.f:
	@mkdir -p $(@D)
	@touch $@

###############################################################################



###############################################################################

test: uv.pytest

.PHONY: uv.pytest
uv.pytest:
	$(uv.exe) run pytest -v -s $(if $(call flexo.true,$(pytest.testmon.enabled)),--testmon)

.PHONY: pytest
pytest: uv.pytest

###############################################################################