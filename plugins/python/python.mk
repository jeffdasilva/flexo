
python.flexo.root_dir := $(abspath $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST)))))
$(call flexo.discover,$(python.flexo.root_dir))

python.exe ?= python3
python.pip.exe = $(python.exe) -m pip
python.test.dir ?= .

python.venv.dir = .venv
python.venv.activate = $(python.venv.dir)/bin/activate

ifeq ($(VIRTUAL_ENV),)

python.venv.setup = $(strip $(if $(or $(wildcard $(python.venv.activate)),$(filter venv,$@ $(MAKECMDGOALS))),\
        source $(python.venv.dir)/bin/activate && ,\
        $(error ERROR: venv not setup. Run 'make venv' to setup)))
endif

.PHONY: venv
ifneq ($(VIRTUAL_ENV),)
venv:
	$(error ERROR: "$@" target not available from within a venv virtual environment. Maybe you want 'make venv_local' instead?)

python.venv_update_target = venv_local

.PHONY: venv_local
venv_local:
	$(MAKE) VENV_DIR= VENV_SETUP= VIRTUAL_ENV= venv

else

python.venv_update_target = venv

venv: requirements.txt
	$(if $(python.venv.dir),$(if $(wildcard $(python.venv.activate)),,$(python.exe) -m venv $(python.venv.dir)))
	$(python.venv.setup) $(python.pip.exe) install --upgrade pip
	$(python.venv.setup) $(python.pip.exe) install -r $<
	$(python.venv.setup) $(python.pip.exe) list

endif

ifneq ($(python.venv.activate),)
ifneq ($(python.venv_update_target),)
$(python.venv.activate): requirements.txt
	$(MAKE) $(python.venv_update_target) python.venv_update_target=
	@[ -f $@ ]
	@touch $@
endif
endif

.PHONY: python.test
python.test:
	$(python.venv.setup) $(python.exe) -m unittest discover -v $(python.test.dir)

python.required_packages += pytest pytest-asyncio
python.required_packages += $(if $(call flexo.true,$(pytest.testmon.enabled)),pytest-testmon)

python.pytest.options += -v -s
python.pytest.options += $(if $(call flexo.true,$(pytest.testmon.enabled)),--testmon)

.PHONY: python.pytest
python.pytest: $(python.venv.activate)
	$(python.venv.setup) $(python.exe) -m pytest $(python.pytest.options)

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


python.required_packages += $(if $(call flexo.true,$(ollama.enabled)),ollama langchain langchain_ollama)
python.required_packages += $(if $(call flexo.true,$(selenium.enabled)),selenium)


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
	$(if $(or $(filter install $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(python.exe))),\
		sudo apt -y install python3 python3-venv python3-pip)

.PHONY: python.install.venv
python.install.venv: python.install

ifeq ($(VIRTUAL_ENV),)
python.install.venv:
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(python.venv.activate))),$(MAKE) venv)
endif

install: python.install python.install.venv