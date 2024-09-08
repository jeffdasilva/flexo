

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

python.required_packages += pytest
.PHONY: python.pytest
python.pytest:
	$(python.venv.setup) $(python.exe) -m pytest -v

.PHONY: pytest
pytest: python.pytest

python.required_packages += black
.PHONY: python.black
python.black:
	$(python.venv.setup) black .

python.required_packages += mypy
python.mypy.options += --strict
python.mypy.options += --ignore-missing-imports

.PHONY: python.mypy
python.mypy:
	$(python.venv.setup) mypy $(python.mypy.options) .


python.required_packages += $(if $(ollama.enabled),ollama langchain langchain_ollama)
python.required_packages += $(if $(selenium.enabled),selenium)


init: python.init
.PHONY: python.init
python.init: python.init.requirements

.PHONY: python.init.requirements
python.init.requirements:
	$(if $(wildcard requirements.txt),,$(strip \
		$(file >requirements.txt)\
		$(foreach package,$(sort $(python.required_packages)),$(file >>requirements.txt,$(package)))\
		$(info INFO: Created requirements.txt)\
		@true \
	))


.PHONY: python.install
python.install:
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(python.exe))),\
		sudo apt -y install python3 python3-venv python3-pip)

.PHONY: python.install.venv
python.install.venv: python.install

ifeq ($(VIRTUAL_ENV),)
python.install.venv:
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(python.venv.activate))),$(MAKE) venv)
endif

install: python.install python.install.venv