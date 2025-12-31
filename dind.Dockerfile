FROM gocd/gocd-agent-docker-dind:v25.4.0
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

USER root
RUN apk upgrade --no-cache && \
    apk add --no-cache ruby-rake ruby-dev build-base && \
	gem install bundler json docker-api --no-document

USER go
