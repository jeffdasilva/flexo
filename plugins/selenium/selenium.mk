# https://www.selenium.dev/

# probably better to just avoid all of this and use package:  webdriver-manager
# https://github.com/jsoma/selenium-github-actions

# webdirver-manager doesn't work with wsl. These instructions seem to do the trick:
# https://cloudbytes.dev/snippets/run-selenium-and-chrome-on-wsl2
# substitute "libasound2t64 libasound2-plugins" instead of "libasound2"
# unfortunately, this install method doesn't work with 'act' under wsl2


selenium.install_dir ?= $(if $(wildcard $(HOME)),$(abspath $(HOME)/.flexo/bin),bin)

#selenium.chrome.exe = google-chrome
selenium.chrome.exe = $(selenium.install_dir)/chrome-linux64/chrome
selenium.chromedriver.exe = $(selenium.install_dir)/chromedriver-linux64/chromedriver

selenium.chrome.installed = $(or $(call have_exe,$(selenium.chrome.exe)),$(wildcard $(selenium.chrome.exe)))
selenium.chromedriver.installed = $(or $(call have_exe,$(selenium.chromedriver.exe)),$(wildcard $(selenium.chromedriver.exe)))

selenium.chrome.latest_url = $(shell \
	curl 'https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json' | \
		jq -r '.channels.Stable.downloads.$1[0].url')

.PHONY: selenium.install
selenium.install:

selenium.install: selenium.chrome.install
.PHONY: selenium.chrome.install
selenium.chrome.install:
ifeq ($(selenium.chrome.exe),google-chrome)

	$(if $(or $(filter $@,$(MAKECMDGOALS)),$(call do_not_have_exe,$(selenium.chrome.exe))),\
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O google-chrome-stable_current_amd64.deb && \
		sudo apt -y install ./google-chrome-stable_current_amd64.deb && \
		rm ./google-chrome-stable_current_amd64.deb)

else # if $(selenium.chrome.exe) is not google-chrome

ifeq ($(selenium.chrome.installed),)

	@echo "[$@] Install prerequisite system packages..."
	sudo apt install -y wget curl unzip jq

	@echo "[$@] Download the latest Chrome binary..."

	mkdir -p $(selenium.install_dir)
	rm -f $(selenium.install_dir)/chrome-linux64.zip*
	wget --directory-prefix=$(selenium.install_dir)/ $(call selenium.chrome.latest_url,chrome)

# This only works with wsl2, and not with 'act' under wsl2. (leave disabled for now)
#	@echo "[$@] Install Chrome dependencies..."
#	sudo apt install -y ca-certificates fonts-liberation \
    	libappindicator3-1 libasound2t64 libasound2-plugins libatk-bridge2.0-0 libatk1.0-0 libc6 \
    	libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 \
    	libgcc1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libpango-1.0-0 \
    	libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
    	libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 \
    	libxrandr2 libxrender1 libxss1 libxtst6 lsb-release wget xdg-utils

	unzip -o $(selenium.install_dir)/chrome-linux64.zip -d $(selenium.install_dir)
	rm -f $(selenium.install_dir)/chrome-linux64.zip

endif # selenium.chrome.installed

endif # if $(selenium.chrome.exe) is google-chrome

selenium.CHROME_VERSION = $(or $(lastword $(shell $(selenium.chrome.exe) --version 2>/dev/null)),$(error ERROR: '$(selenium.chrome.exe) --version' failed to return a version number))

selenium.install: selenium.chromedriver.install
.PHONY: selenium.chromedriver.install
selenium.chromedriver.install: selenium.chrome.install

selenium.chromedriver.install:
ifeq ($(selenium.chromedriver.installed),)

	@echo "[$@] Download the latest Chromedriver binary..."

	mkdir -p $(selenium.install_dir)
	rm -f $(selenium.install_dir)/chromedriver-linux64.zip*
	wget --directory-prefix=$(selenium.install_dir)/  $(call selenium.chrome.latest_url,chromedriver)

	unzip -o $(selenium.install_dir)/chromedriver-linux64.zip -d $(selenium.install_dir)
	rm -f $(selenium.install_dir)/chromedriver-linux64.zip

endif