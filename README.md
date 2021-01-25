# nats-auto-server

> The Nats MQ server with start up scripts that automates operator and account setup from seeds

## Howto

```bash
docker build --no-cache=true -t mheers/nats-auto-server .
docker push mheers/nats-auto-server
```

## Change startup behaviour

Mount a different config to `/nats/conf/nats-server.conf.template`

## Add additional config

Mount an additional config to `/nats/conf/additional.conf`

## Local development

docker run --entrypoint /bin/sh --rm synadia/nats-server:nightly-20210123 -c "/bin/cat /bin/nats-server" > nats-server && chmod +x nats-server
./nats-server -c nats-server.conf
