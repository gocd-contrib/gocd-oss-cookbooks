FROM gocd/gocd-agent-docker-dind:v23.1.0

USER root
RUN apk add --no-cache ruby-rake ruby-dev build-base && \
	gem install bundler json docker-api --no-document

# Temporary workaround for https://github.com/gocd/gocd/issues/11378
COPY --chmod=555 provision/run-docker-daemon.sh /

USER go
