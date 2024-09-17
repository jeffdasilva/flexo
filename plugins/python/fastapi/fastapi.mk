# https://fastapi.tiangolo.com/

python.required_packages += fastapi[standard]

fastapi.exe ?= fastapi
fastapi.main ?= main.py
fastapi.port ?= 8000
fastapi.subcmd ?= $(if $(filter run dev,$*),$*,run)
fastapi.cmd = $(fastapi.exe) $(fastapi.subcmd) $(fastapi.main) $(if $(fastapi.port),--port 8000)

.PHONY: fastapi.dev fastapi.run
fastapi.dev fastapi.run: fastapi.%:
	$(python.venv.setup) $(fastapi.cmd)

install: fastapi.install

.PHONY: fastapi.install
fastapi.install: python.install python.install.venv
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(fastapi.exe))),\
		$(python.venv.setup) $(python.pip.exe) install fastapi[standard])

