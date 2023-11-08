#!/usr/bin/env bash

set -eo pipefail

cd /nats/conf/
echo "starting . . ."
if [ "$AUTO" != "off" ]; then
    echo "running auto configuration"
    cp ./nats-server.conf.template ./nats-server.conf

    if [ -n "$OPERATOR_SEED" ] && [ -n "$ACCOUNT_SEED" ] && [ -n "$SYS_ACCOUNT_SEED" ]; then
        if [ "$NO_AUTH" == "true" ]; then
            echo "no auth enabled AND seeds provided - choose one"
            exit 1
        fi
        # create operator
        OPERATOR_JWT=$(nats-seeder operator-jwt -o $OPERATOR_SEED -a $OPERATOR_SEED)
        echo operator: ${OPERATOR_JWT} >> nats-server.conf

        echo resolver: MEMORY >> nats-server.conf
        echo resolver_preload: { >> nats-server.conf

        # create account
        ACCOUNT_JWT=$(nats-seeder account-jwt -o $OPERATOR_SEED -a $ACCOUNT_SEED -b $SYS_ACCOUNT_SEED)
        ACCOUNT_PK=$(nats-seeder account-public-key -o $OPERATOR_SEED -a $ACCOUNT_SEED -b $SYS_ACCOUNT_SEED)
        echo   $ACCOUNT_PK: "$ACCOUNT_JWT" >> nats-server.conf
        # create sys account
        SYS_ACCOUNT_JWT=$(nats-seeder sys-account-jwt -o $OPERATOR_SEED -a $ACCOUNT_SEED -b $SYS_ACCOUNT_SEED)
        SYS_ACCOUNT_PK=$(nats-seeder sys-account-public-key -o $OPERATOR_SEED -a $ACCOUNT_SEED -b $SYS_ACCOUNT_SEED)
        echo   $SYS_ACCOUNT_PK: "$SYS_ACCOUNT_JWT" >> nats-server.conf
        
        echo } >> nats-server.conf
        echo system_account: $SYS_ACCOUNT_PK >> nats-server.conf
    else
        echo "no seeds provided"
        if [ "$NO_AUTH" == "true" ]; then    
            echo "no auth enabled - starting server without auth"
        else
            echo "no OPERATOR_SEED, ACCOUNT_SEED & SYS_ACCOUNT_SEED provided and NO_AUTH is not true - exiting"
            exit 1
        fi
    fi

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
fi

echo "Using config:"
cat ./nats-server.conf

exec nats-server -c ./nats-server.conf
