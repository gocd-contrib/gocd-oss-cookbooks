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

# Mount a docker volume to improve performance and reduce change of storage issues with dind-in-dind
# https://github.com/docker-library/docker/blob/319e58aa0299128924649f0745054a1b8732545a/29/dind/Dockerfile#L104
VOLUME /var/lib/docker

CMD ["/bin/bash", "-lc", "/go/go-agent"]
