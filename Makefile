DATE = $(shell date +%Y%m%d%H%M)
VERSION = v$(DATE)
GOOS ?= $(shell go env | grep GOOS | cut -d'"' -f2)
BINARY := grafzahl

LDFLAGS := -X github.com/Dbaker1298/grafzahl/pkg/operator.VERSION=$(VERSION)
GOFLAGS := -ldflags "$(LDFLAGS)"
PACKAGES := $(shell find $(SRCDIRS) -type d)
GOFILES := $(addsuffix /*.go,$(PACKAGES))
GOFILES := $(wildcard $(GOFILES))

.PHONY: all clean

all: bin/$(GOOS)/$(BINARY)
bin/%/$(BINARY): $(GOFILES) Makefile
	GOARCH=amd64 go build $(GOFLAGS) -v -o $(BINARY) cmd/main.go