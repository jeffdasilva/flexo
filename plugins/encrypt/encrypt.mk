

#encrypt.files =
encrypt.files_enc = $(addsuffix .enc,$(encrypt.files))

.PHONY: decrypt
decrypt: $(encrypt.files)

.PHONY: encrypt
encrypt: $(encrypt.files_enc)

ifeq ($(filter decrypt,$(MAKECMDGOALS)),decrypt)

ifeq ($(FORCE),YES)
.PHONY: $(encrypt.files)
endif

 $(encrypt.files): %: %.enc
ifeq ($(FORCE),YES)
	$(if $(wildcard $@),@mv $@ $@.bak)
else
	$(if $(wildcard $@),$(error ERROR: $@ already exists. Refusing to overwrite without FORCE=YES))
endif
	openssl enc -aes-256-cbc -d -md sha512 -pbkdf2 -iter 100000 -salt -in $< -out $@

ifeq ($(FORCE),YES)
	@if [ -f $@.bak ]; then \
		echo "Diff of $@.bak and $@"; \
		diff -u $@.bak $@; \
		$(RM) $@.bak; \
	fi
endif

else ifeq ($(filter encrypt,$(MAKECMDGOALS)),encrypt)

$(encrypt.files_enc): %.enc: %
	openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -in $< -out $@

endif

.PHONY: encrypt.install
encrypt.install:
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,openssl)),sudo apt -y install openssl)

install: encrypt.install