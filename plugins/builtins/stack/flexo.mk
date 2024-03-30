

define stack.push
$(strip \
$(if $1,,$(error ARG1 [stack_variable_name] not specified for function $0))
$(if $2,,$(error ARG2 [variable_to_save] not specified for function $0))
$(eval stack.$1.counter += x)
$(eval stack.$1.$(words $(stack.$1.counter)) := $2)
)
endef

define stack.pop
$(strip \
$(if $1,,$(error ARG1 [stack_variable_name] not specified for function $0))
$(if $(stack.$1.counter),,$(error ERROR: $0($1) failed. Stack is empty))
$(eval $1 := $(stack.$1.$(words $(stack.$1.counter))))
$(eval undefine stack.$1.$(words $(stack.$1.counter)))
$(eval stack.$1.counter := $(wordlist 2,$(words $(stack.$1.counter)),$(stack.$1.counter)))
)
endef

################
# Example Usage:
# $(call stack.push,SOME_VAR,1 2 3)
# $(call stack.push,SOME_VAR,4 5 6)
# $(call stack.push,SOME_VAR,7 8 9)
# $(call stack.pop,SOME_VAR)
# $(info SOME_VAR is $(SOME_VAR))
# $(call stack.pop,SOME_VAR)
# $(info SOME_VAR is $(SOME_VAR))
# $(call stack.pop,SOME_VAR)
# $(info SOME_VAR is $(SOME_VAR))
# undefine SOME_VAR
################
