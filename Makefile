all: build

include .env
export

build:
	docker build --build-arg NATS_VERSION=$(NATS_VERSION) --no-cache=true -t mheers/nats-auto-server:$(NATS_VERSION) .

push:
	docker push mheers/nats-auto-server:$(NATS_VERSION)

start:
	docker-compose up
