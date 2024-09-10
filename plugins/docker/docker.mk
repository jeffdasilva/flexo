# https://www.docker.com/
# https://docs.docker.com/engine/install/ubuntu/

docker.exe ?= docker

.PHONY: docker.run
docker.run: docker.compose

.PHONY: docker.compose
docker.compose:
	$(docker.exe) compose up --build

.PHONY: docker.init
docker.init:
	$(docker.exe) init

.PHONY: docker.install
docker.install:
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	sudo $(docker.exe) run hello-world
