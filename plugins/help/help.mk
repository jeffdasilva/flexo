

help.variables = $(filter-out FLEXO.%,$(filter %.help,$(.VARIABLES)))
help.targets = $(patsubst %.help,help.%,$(help.variables))

help.targets.default_target = $(filter $(.DEFAULT_GOAL).help,$(help.targets))
help.targets.the_rest = $(sort \
	$(filter-out \
		$(help.targets.default_target), \
		$(help.targets) \
	))
help.targets_sorted = $(help.targets.default_target) $(help.targets.the_rest)

help.help = Display this information
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
$(foreach target,$(help.targets_sorted),\
	$(eval help: $(target))\
	$(eval $(call help.generate_target,$(target)))\
)
endef
