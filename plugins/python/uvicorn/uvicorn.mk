# https://www.uvicorn.org/

uvicorn.python_packages = uvicorn uvicorn-worker gunicorn
python.required_packages += $(uvicorn.python_packages)

uvicorn.exe ?= uvicorn
#uvicorn.app_dir ?= app
uvicorn.main ?= main:app

uvicorn.log_conf ?= log_conf.yaml
uvicorn.args += $(if $(wildcard $(uvicorn.log_conf)),--log-config $(uvicorn.log_conf))
#uvicorn.args += --log-level info

uvicorn.host ?= 0.0.0.0
uvicorn.port ?= 8000

uvicorn.args += $(if $(uvicorn.host),--host=$(uvicorn.host))
uvicorn.args += $(if $(uvicorn.port),--port=$(uvicorn.port))

uvicorn.reload ?= $(or $(reload),$(RELOAD))
uvicorn.args += $(if $(call flexo.true,$(uvicorn.reload)),--reload $(patsubst %,--reload-exclude=%,$(uvicorn.reload_exclude)))

uvicorn.args += $(if $(uvicorn.app_dir),--app-dir=$(uvicorn.app_dir))

.PHONY: uvicorn.run
uvicorn.run:
	$(python.venv.setup) $(uvicorn.exe) $(uvicorn.main) $(uvicorn.args)

.PHONY: uvicorn.install
uvicorn.install: python.install python.install.venv
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(uvicorn.exe))),\
		$(python.venv.setup) $(python.pip.exe) install $(uvicorn.python_packages))

install: uvicorn.install