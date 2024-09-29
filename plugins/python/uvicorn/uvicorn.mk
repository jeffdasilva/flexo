# https://www.uvicorn.org/

uvicorn.python_packages = uvicorn uvicorn-worker gunicorn
python.required_packages += $(uvicorn.python_packages)

uvicorn.exe ?= uvicorn
#uvicorn.app_dir ?= app
uvicorn.main ?= main:app

.PHONY: uvicorn.run
uvicorn.run:
	$(python.venv.setup) $(uvicorn.exe) $(uvicorn.main) --reload $(if $(uvicorn.app_dir),--app-dir=$(uvicorn.app_dir))

.PHONY: uvicorn.install
uvicorn.install: python.install python.install.venv
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(uvicorn.exe))),\
		$(python.venv.setup) $(python.pip.exe) install $(uvicorn.python_packages))

install: uvicorn.install