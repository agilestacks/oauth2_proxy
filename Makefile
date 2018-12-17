.DEFAULT_GOAL := compile

export GOPATH            ?= $(abspath .)
export GOOS              ?= $(shell uname -s | tr A-Z a-z)
export GOBIN             ?= $(GOPATH)/bin/$(GOOS)
export PATH              ?= $(GOBIN):$(PATH)
export GOAPP             ?= oauth2_proxy
export IMAGE              	?= docker.io/agilestacks/$(GOAPP)
export IMAGE_VERSION      	?= v2.3

DOCKER_BUILD_OTPS := --no-cache  --force-rm "

deploy: build push

install:
	go get -u github.com/mitchellh/gox
	go get -u github.com/nsf/gocode
	go get -u golang.org/x/tools/cmd/guru
	go get -u golang.org/x/tools/cmd/goimports
	go get -u golang.org/x/tools/cmd/gorename
	go get -u github.com/golang/lint/golint
	go get -u golang.org/x/tools/cmd/guru
	go get -u golang.org/x/tools/cmd/godoc

compile:
	$(GOBIN)/gox -rebuild -verbose \
		-ldflags='-extldflags "-static"' \
		-osarch="darwin/amd64 linux/amd64" \
		-output=$(GOPATH)/bin/{{.OS}}/{{.Dir}} \
		.

vendor:
	go mod vendor

get:
	go get $(GOAPP)

clean:
	@yes n | rm -rf .cache | true
	@yes n | rm -rf pkg | true
	@yes n | rm -rf bin/$(GOOS) | true
	@yes n | rm -rf linux/$(GOOS) | true
	@yes n | rm -rf dist | true
	@yes n | rm -rf vendor | true

build: vendor
	docker build $(DOCKER_BUILD_OPTS) \
		-t $(IMAGE):$(IMAGE_VERSION) \
		-t $(IMAGE):latest .
.PHONY: build

push:
	docker tag  $(IMAGE):$(IMAGE_VERSION) $(IMAGE):latest
	docker push $(IMAGE):$(IMAGE_VERSION)
	docker push $(IMAGE):latest
.PHONY: push

output:
	@echo Outputs:
	@echo docker_image=$(IMAGE):$(IMAGE_VERSION)
	@echo Agile Stacks Inc $(GOAPP)
.PHONY: output


undeploy:
	@echo "Operation [undeploy] not yet supported. Skip..."
.PHONY: undeploy
