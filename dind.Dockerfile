FROM gocd/gocd-agent-docker-dind:v24.2.0

USER root
RUN apk upgrade --no-cache && \
        apk add --no-cache ruby-rake ruby-dev build-base && \
	gem install bundler json docker-api --no-document

USER go
