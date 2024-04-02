

recursive_make.targets ?= all

recursive_make.subdirs ?=

define recursive_make.generate
$(foreach target,$(recursive_make.targets),
	$(eval .PHONY: $(target))
	$(foreach subdir,$(recursive_make.subdirs),
		$(eval $(target): $(target)-$(subdir))
		$(eval .PHONY: $(target)-$(subdir))\
		$(eval \
		$(target)-$(subdir):
			$(MAKE) -C $(subdir) $(target)
		) 
	)
)
endef

