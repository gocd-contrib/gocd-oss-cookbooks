FROM ubuntu:24.04
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

COPY provision /usr/local/src/provision/

RUN --mount=type=secret,id=github_token,target=/run/secrets/github_token,mode=0444,required=true \
    /usr/local/src/provision/provision-ubuntu.sh

# Create volume where the golang-gocd-bootstrapper will use as work dir
RUN mkdir -p /go-working-dir && chown go:go /go-working-dir
VOLUME /go-working-dir
USER go

# force encoding
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

ENV PATH="/go/.local/share/mise/shims:${PATH}"
ENTRYPOINT ["tini", "--"]
CMD ["go-agent"]
