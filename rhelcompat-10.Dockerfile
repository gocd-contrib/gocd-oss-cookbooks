FROM almalinux:10
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

ARG BUILDARCH
ARG TARGETARCH

COPY provision /usr/local/src/provision/

RUN /usr/local/src/provision/provision-rhelcompat.sh

ENTRYPOINT ["/usr/bin/tini", "--"]

USER go

# force encoding
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

CMD ["/bin/bash", "-lc", "/go/go-agent"]
