

os.is_wsl = $(if $(wildcard /proc/version),$(if $(findstring microsoft,$(call tolower,$(file < /proc/version))),T))
