FROM gocd/gocd-agent-docker-dind:v23.5.0

USER root
RUN apk add --no-cache ruby-rake ruby-dev build-base && \
	gem install bundler json docker-api --no-document

USER go
