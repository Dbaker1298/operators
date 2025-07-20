VERSION ?= $(shell git describe --always 2>/dev/null || echo "0.0.1")
REGISTRY ?= docker.io
ORG ?= dbaker1298
PROJ ?= grafzahl
IMG := $(REGISTRY)/$(ORG)/$(PROJ):$(VERSION)

docker-build:
	docker build -t $(IMG) .

docker-push:
	docker push $(IMG)