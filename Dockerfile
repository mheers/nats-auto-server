FROM nats:2.2.0-alpine3.13

RUN apk add curl wget nano bash jq

COPY --from=mheers/nats-seeder /usr/local/bin/nats-seeder /usr/local/bin/

WORKDIR /nats/conf/
ADD nats-server.conf.template ./
ADD additional.conf ./

EXPOSE 4222 9222

ADD autostart.sh /autostart.sh
RUN chmod +x /autostart.sh

CMD [ "/autostart.sh" ]
