FROM alpine:3.17.2

RUN apk update && \
    apk add openssl && \
    apk add bash && \
    chmod +x /scripts/*.sh

USER 1000:1000

ADD conf /conf
ADD *.sh /scripts/

ENTRYPOINT [ "/scripts/wrapper.sh" ]