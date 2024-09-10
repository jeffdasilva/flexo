# https://ollama.com/
# https://github.com/ollama/ollama

# https://ollama.com/download/linux
# https://github.com/ollama/ollama/blob/main/docs/linux.md

ollama.exe ?= ollama

ollama.model ?= llama3.1
#ollama.model ?= llama3.1:70b
#ollama.model ?= mistral

.PHONY: ollama.run
ollama.run:
	@echo "INFO: About to launch ollama with model '$(ollama.model)'. Use command '/bye' to exit out of the ollama chat."
	ollama run $(ollama.model)

.PHONY: ollama.serve
ollama.serve:
	ollama serve

install: ollama.install
.PHONY: ollama.install
ollama.install:
	$(if $(call have_exe,$(ollama.exe)),,curl -fsSL https://ollama.com/install.sh | sh)

install: ollama.install.model
.PHONY: ollama.install.model
ollama.install.model: ollama.install
	$(ollama.exe) pull $(ollama.model)
