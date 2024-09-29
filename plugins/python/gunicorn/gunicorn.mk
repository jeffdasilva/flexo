# https://gunicorn.org/
# https://www.geeksforgeeks.org/fast-api-gunicorn-vs-uvicorn/
# https://www.uvicorn.org/

$(call flexo.add,uvicorn)

gunicorn.python_packages = gunicorn
python.required_packages += $(gunicorn.python_packages)

gunicorn.exe ?= gunicorn
gunicorn.app_dir ?= $(uvicorn.app_dir)
gunicorn.main ?= $(uvicorn.main)

#gunicorn.args += --reload

.PHONY: gunicorn.run
gunicorn.run:
	$(python.venv.setup) $(gunicorn.exe) $(gunicorn.main) $(gunicorn.args) --log-level info --workers 4 -k uvicorn.workers.UvicornWorker --bind=0.0.0.0:8000

.PHONY: gunicorn.install
gunicorn.install: python.install python.install.venv
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(gunicorn.exe))),\
		$(python.venv.setup) $(python.pip.exe) install $(gunicorn.python_packages))

install: gunicorn.install