

#clean.files +=
#clean.directories +=

clean.help = Clean up your workspace
.PHONY: clean
clean: clean-files clean-directories

.PHONY: clean-files clean-directories
clean-files clean-directories: clean-%:
	$(if $(wildcard $(clean.$*)),$(RM) $(if $(filter directories,$*),--recursive )$(wildcard $(clean.$*)))
