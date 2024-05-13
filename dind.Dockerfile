FROM gocd/gocd-agent-docker-dind:v24.1.0

USER root
RUN apk add --no-cache ruby-rake ruby-dev build-base && \
	gem install bundler json docker-api --no-document

USER go
