ARG NATS_VERSION=2.10.18-alpine3.20
FROM nats:${NATS_VERSION}

RUN apk add curl wget nano bash jq

COPY --from=mheers/nats-seeder /usr/local/bin/nats-seeder /usr/local/bin/
COPY --from=mheers/nats-seeder /usr/local/bin/nats /usr/local/bin/

WORKDIR /nats/conf/
ADD nats-server.conf.template ./
ADD additional.conf ./

EXPOSE 4222 8222 9222

ADD autostart.sh /autostart.sh
RUN chmod +x /autostart.sh

CMD [ "/autostart.sh" ]
