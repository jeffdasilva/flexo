
builtins.root_dir := $(abspath $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST)))))
$(call flexo.discover,$(builtins.root_dir))