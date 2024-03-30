

formatter.files ?= $(git.ls-files)

.PHONY: formatter.remove-trailing-whitespace
formatter.remove-trailing-whitespace: $(patsubst %,%.formatter.remove-trailing-whitespace,$(formatter.files))

.PHONY: $(patsubst %,%.formatter.remove-trailing-whitespace,$(formatter.files))
$(patsubst %,%.formatter.remove-trailing-whitespace,$(formatter.files)): %.formatter.remove-trailing-whitespace: %
	@echo "Removing trailing whitespace from $<..."
#	$(QUIET)sed -i 's/[[:space:]]*$//' $<

.PHONY: format
format: formatter.remove-trailing-whitespace

