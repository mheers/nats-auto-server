FROM alpine:3.12

RUN apk add curl wget nano bash jq

COPY --from=synadia/nats-server:nightly-20200924 /bin/nats-server /usr/local/bin/
COPY --from=mheers/nats-seeder /usr/local/bin/nats-seeder /usr/local/bin/

WORKDIR /nats/conf/
ADD nats-server.conf.template ./

EXPOSE 4222 9222

ADD autostart.sh /autostart.sh
RUN chmod +x /autostart.sh

CMD [ "/autostart.sh" ]
