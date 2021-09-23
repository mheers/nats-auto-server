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

```bash
docker run --entrypoint /bin/sh --rm synadia/nats-server:nightly-20210123 -c "/bin/cat /bin/nats-server" > nats-server && chmod +x nats-server
./nats-server -c nats-server.conf
```

## Test

```bash
export OPERATOR_SEED=SOAON2QVZ5L7CMOO5W3PV4F7OCDU7L6AXIO5VA2YWIBTTSLUN64UNOU63M
export SYS_ACCOUNT_SEED=SAABOFAWXZYMP3LWVULJTFD25YDFA5UEJ4FRIELRRIHQNMSQFDWKLNXS5E
export ACCOUNT_SEED=SAADBIEN2MTECGRQDK3Y6XHK7PADDSXR6SOCQOM5GFORHLBAX6V6C65OOE

nats-seeder user-jwt -o $OPERATOR_SEED -a $ACCOUNT_SEED -b $SYS_ACCOUNT_SEED
nats-seeder user-public-key -o $OPERATOR_SEED -a $ACCOUNT_SEED -b $SYS_ACCOUNT_SEED
```
