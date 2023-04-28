FROM gocdexperimental/gocd-agent-docker-dind:v23.2.0-16389

USER root
RUN apk add --no-cache ruby-rake ruby-dev build-base && \
	gem install bundler json docker-api --no-document

USER go
