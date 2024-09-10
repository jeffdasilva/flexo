# https://streamlit.io/

python.required_packages += streamlit

streamlit.exe ?= streamlit
streamlit.main ?= main.py
streamlit.port ?= 8000
streamlit.cmd = $(streamlit.exe) run $(streamlit.main) $(if $(streamlit.port),--server.port 8000)

.PHONY: streamlit.run
streamlit.run:
	$(python.venv.setup) $(streamlit.cmd)

install: streamlit.install

.PHONY: streamlit.install
streamlit.install: python.install python.install.venv
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(streamlit.exe))),\
		$(python.venv.setup) $(python.pip.exe) install streamlit)

