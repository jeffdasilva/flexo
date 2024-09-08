# https://www.selenium.dev/

selenium.chrome.exe = google-chrome
selenium.chromedriver.exe = chromedriver

.PHONY: selenium.install
selenium.install:

selenium.install: selenium.chrome.install
.PHONY: selenium.chrome.install
selenium.chrome.install:
	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(selenium.chrome.exe))),\
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O google-chrome-stable_current_amd64.deb && \
		sudo apt -y install ./google-chrome-stable_current_amd64.deb && \
		rm ./google-chrome-stable_current_amd64.deb)

selenium.CHROME_VERSION = $(or $(lastword $(shell $(selenium.chrome.exe) --version 2>/dev/null)),$(error ERROR: '$(selenium.chrome.exe) --version' failed to return a version number))
selenium.install: selenium.chromedriver.install
.PHONY: selenium.chromedriver.install
selenium.chromedriver.install: selenium.chrome.install

ifneq ($(or $(filter selenium.chromedriver.install,$(MAKECMDGOALS)),$(call do_not_have_exe,$(selenium.chromedriver.exe))),)
selenium.chromedriver.install:
	@rm -rf chromedriver-linux64 chromedriver-linux64.zip
	wget https://storage.googleapis.com/chrome-for-testing-public/$(selenium.CHROME_VERSION)/linux64/chromedriver-linux64.zip -O chromedriver-linux64.zip
	unzip chromedriver-linux64.zip
	@mkdir -p $(dir $(selenium.chromedriver.exe))
	cp -f chromedriver-linux64/chromedriver $(selenium.chromedriver.exe)
	@rm -rf chromedriver-linux64 chromedriver-linux64.zip
endif

install: selenium.install