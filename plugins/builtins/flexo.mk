
builtins.root_dir := $(abspath $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST)))))

$(call flexo.discover,$(builtins.root_dir))
$(call flexo.add,stack)
$(call flexo.add,os)