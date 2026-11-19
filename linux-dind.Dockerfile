FROM gocd/gocd-agent-docker-dind:v26.1.0
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

USER root
RUN apk upgrade --no-cache && \
    apk add --no-cache ruby-rake ruby-dev build-base && \
	gem install bundler json docker-api --no-document

COPY provision-linux/gocd-sudoers /etc/sudoers.d/go
COPY provision-linux/dind-configure-mirror /docker-entrypoint.d/dind-configure-mirror

USER go
