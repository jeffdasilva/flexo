

help.variables = $(filter-out FLEXO.%,$(filter %.help,$(.VARIABLES)))
help.targets = $(patsubst %.help,help.%,$(help.variables))

.PHONY: help
help:

define help.generate_target
$(flexo.debug.call)
$(eval .PHONY: $1)
$(eval \
$1: help.%:
	$$(info $$*: $$($$*.help) $$(if $$(filter $$*,$$(.DEFAULT_GOAL)),(default)))
	@true
)
endef

define help.generate
$(foreach target,$(help.targets),\
	$(eval help: $(target))\
	$(eval $(call help.generate_target,$(target)))\
)
endef
