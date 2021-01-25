all: build

build:
	docker build --no-cache=true -t mheers/nats-auto-server .

push:
	docker push mheers/nats-auto-server
