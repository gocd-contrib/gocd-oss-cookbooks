FROM ubuntu:22.04
MAINTAINER GoCD Team <go-cd-dev@googlegroups.com>

COPY provision /usr/local/src/provision/

RUN /usr/local/src/provision/provision-ubuntu.sh

ENTRYPOINT ["/usr/bin/tini", "--"]

USER go

# force encoding
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD ["/go/go-agent"]
