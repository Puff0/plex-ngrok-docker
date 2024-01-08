FROM alpine:3.12
MAINTAINER Werner Beroux <werner@beroux.com>

# https://github.com/sgerrand/alpine-pkg-glibc
ARG GLIBC_VERSION=2.31-r0

RUN set -x \
 && apk add --no-cache -t .deps ca-certificates \
    # Install glibc on Alpine (required by docker-compose)
    # See also https://github.com/gliderlabs/docker-alpine/issues/11
 && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
 && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
 && apk add glibc-${GLIBC_VERSION}.apk \
 && rm glibc-${GLIBC_VERSION}.apk \
 && apk del --purge .deps

RUN set -x \
    # Install ngrok (latest official stable from https://ngrok.com/download).
 && apk add --no-cache curl \
 && APKARCH="$(apk --print-arch)" \
 && case "$APKARCH" in \
      armhf)   NGROKARCH="arm" ;; \ 
      armv7)   NGROKARCH="arm" ;; \
      armel)   NGROKARCH="arm" ;; \
      x86)     NGROKARCH="386" ;; \
      x86_64)  NGROKARCH="amd64" ;; \
    esac \
 && curl -Lo /ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-$NGROKARCH.tgz \
 && tar -xzf /ngrok.tgz \
 && mv /ngrok /bin \
 && chmod 755 /bin/ngrok \
 && rm -f /ngrok.tgz \
    # Create non-root user.
 && adduser -h /home/ngrok -D -u 6737 ngrok

RUN set -x \
    # install python 3 and plexapi
 && apk add --no-cache python3 \
 && python3 -m ensurepip \
 && rm -r /usr/lib/python*/ensurepip \
 && pip3 install --upgrade pip setuptools \
 && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
 && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
 && rm -r /root/.cache \
 && pip3 install plexapi \
 && apk add nano

# Add config script.
COPY --chown=ngrok ngrok.yml /home/ngrok/.ngrok2/
COPY entrypoint.sh /
COPY plexurl.py /

RUN chmod +x plexurl.py

USER ngrok
ENV USER=ngrok

EXPOSE 4040

CMD ["/entrypoint.sh"]
