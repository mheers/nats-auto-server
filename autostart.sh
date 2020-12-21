#!/usr/bin/env bash

set -eo pipefail

cd /nats/conf/

cp ./nats-server.conf.template ./nats-server.conf

OPERATOR_JWT=$(nats-seeder operator-jwt -o $OPERATOR_SEED -a $OPERATOR_SEED)
sed -i "s#\$OPERATOR_JWT#${OPERATOR_JWT}#g" nats-server.conf

ACCOUNT_JWT=$(nats-seeder account-jwt -o $OPERATOR_SEED -a $ACCOUNT_SEED)
ACCOUNT_PK=$(nats-seeder account-public-key -o $OPERATOR_SEED -a $ACCOUNT_SEED)
sed -i "s#\$ACCOUNT_PK#${ACCOUNT_PK}#g" nats-server.conf
sed -i "s#\$ACCOUNT_JWT#${ACCOUNT_JWT}#g" nats-server.conf

# TODO: do not start if no authentication is available

echo "Using config:"
cat ./nats-server.conf

exec nats-server -c ./nats-server.conf
