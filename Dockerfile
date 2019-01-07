FROM alpine:3.8
MAINTAINER Werner Beroux <werner@beroux.com>

RUN set -x \
    # Install ngrok (latest official stable from https://ngrok.com/download).
 && apk add --no-cache curl \
 && curl -Lo /ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip \
 && unzip -o /ngrok.zip -d /bin \
 && rm -f /ngrok.zip \
    # Create non-root user.
 && adduser -h /home/ngrok -D -u 6737 ngrok
 
RUN set -x \
    # install python 3 and plexapi
&& apk add --no-cache python3 \
&& alias python=python3
&& apk add py-pip \
&& pip install plexapi
&& apk add nano

# Add config script.
COPY ngrok.yml /home/ngrok/.ngrok2/
COPY entrypoint.sh /
COPY plexurl.py /

USER ngrok
ENV USER=ngrok

EXPOSE 4040

CMD ["/entrypoint.sh"]
