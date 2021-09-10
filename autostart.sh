#!/usr/bin/env bash

set -eo pipefail

cd /nats/conf/
echo "starting . . ."
if [ "$AUTO" != "off" ]; then
    echo "running auto configuration"
    cp ./nats-server.conf.template ./nats-server.conf

    # create operator
    OPERATOR_JWT=$(nats-seeder operator-jwt -o $OPERATOR_SEED -a $OPERATOR_SEED)
    sed -i "s#\$OPERATOR_JWT#${OPERATOR_JWT}#g" nats-server.conf

    # create account
    ACCOUNT_JWT=$(nats-seeder account-jwt -o $OPERATOR_SEED -a $ACCOUNT_SEED)
    sed -i "s#\$ACCOUNT_JWT#${ACCOUNT_JWT}#g" nats-server.conf
    ACCOUNT_PK=$(nats-seeder account-public-key -o $OPERATOR_SEED -a $ACCOUNT_SEED)
    sed -i "s#\$ACCOUNT_PK#${ACCOUNT_PK}#g" nats-server.conf

    # create sys account
    SYS_ACCOUNT_JWT=$(nats-seeder account-jwt -o $OPERATOR_SEED -a $ACCOUNT_SEED)
    sed -i "s#\$SYS_ACCOUNT_JWT#${SYS_ACCOUNT_JWT}#g" nats-server.conf
    SYS_ACCOUNT_PK=$(nats-seeder account-public-key -o $OPERATOR_SEED -a $ACCOUNT_SEED)
    sed -i "s#\$SYS_ACCOUNT_PK#${SYS_ACCOUNT_PK}#g" nats-server.conf

    # adjust websocket port if defined
    if [ -n "$WEBSOCKET_PORT" ]; then
        sed -i "s#\$WEBSOCKET_PORT#${WEBSOCKET_PORT}#g" nats-server.conf
    else 
        sed -i "s#\$WEBSOCKET_PORT#9222#g" nats-server.conf
    fi

    if [ "$TLS" == "true" ]; then
        echo "configuring tls"
        TLS_CONFIG=$(cat << END
            tls: {
                cert_file: "./server-cert.pem",
                key_file: "./server-key.pem"
            }
END
)
        TLS_CONFIG=`echo ${TLS_CONFIG} | tr '\n' "\\n"`
        echo "using tls config: ${TLS_CONFIG}" 
        sed -i "s#\$TLS_CONFIG#${TLS_CONFIG}#g" nats-server.conf
    else
        sed -i "s#\$TLS_CONFIG#no_tls: true#g" nats-server.conf
    fi

    # TODO: do not start if no authentication is available
fi

echo "Using config:"
cat ./nats-server.conf

exec nats-server -c ./nats-server.conf
