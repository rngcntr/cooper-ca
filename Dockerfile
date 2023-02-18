FROM alpine:3.17.2

ADD conf /conf
ADD *.sh /scripts/

RUN apk update && \
    apk add openssl && \
    apk add bash && \
    chmod +x /scripts/*.sh

USER 1000:1000

ENTRYPOINT [ "/scripts/wrapper.sh" ]
