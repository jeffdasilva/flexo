

python.exe = python3
python.pip.exe = $(python.exe) -m pip
python.test.dir ?= .

python.venv.dir = .venv

ifeq ($(VIRTUAL_ENV),)

python.venv.activate = $(python.venv.dir)/bin/activate

python.venv.setup = $(strip $(if $(or $(wildcard $(python.venv.activate)),$(filter venv,$@ $(MAKECMDGOALS))),\
        source $(python.venv.dir)/bin/activate && ,\
        $(error ERROR: venv not setup. Run 'make venv' to setup)))
endif

.PHONY: venv
ifneq ($(VIRTUAL_ENV),)
venv:
	$(error ERROR: "$@" target not available from within a venv virtual environment. Maybe you want 'make venv_local' instead?)

.PHONY: venv_local
venv_local:
	$(MAKE) VENV_DIR= VENV_SETUP= VIRTUAL_ENV= venv

else
venv: requirements.txt
	$(if $(python.venv.dir),$(if $(wildcard $(python.venv.activate)),,$(python.exe) -m venv $(python.venv.dir)))
	$(python.venv.setup) $(python.pip.exe) install --upgrade pip
	$(python.venv.setup) $(python.pip.exe) install -r $<
	$(python.venv.setup) $(python.pip.exe) list
endif

.PHONY: python.test
python.test:
	$(python.venv.setup) $(python.exe) -m unittest discover -v $(python.test.dir)

.PHONY: python.pytest
python.pytest:
	$(python.venv.setup) $(python.exe) -m pytest -v

.PHONY: pytest
pytest: python.pytest

.PHONY: python.black
python.black:
	$(python.venv.setup) black .


python.mypy.options += --strict
#python.mypy.options += --ignore-missing-imports

.PHONY: python.mypy
python.mypy:
	$(python.venv.setup) mypy $(python.mypy.options) .

