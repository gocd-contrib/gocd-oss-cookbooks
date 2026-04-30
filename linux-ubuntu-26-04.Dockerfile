FROM ubuntu:26.04
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

ARG PROVISION_SCRIPTS_DIR=/usr/local/src/provision
ARG GITHUB_TKN_FILE=/run/secrets/github_token
COPY provision provision-linux $PROVISION_SCRIPTS_DIR
RUN --mount=type=secret,id=github_token,target=$GITHUB_TKN_FILE,mode=0444,required=true \
    $PROVISION_SCRIPTS_DIR/provision-ubuntu.sh

# Create volume where the golang-gocd-bootstrapper will use as work dir
RUN mkdir -p /go-working-dir && chown go:go /go-working-dir
VOLUME /go-working-dir
USER go

# force encoding
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PATH="/go/.local/share/mise/shims:/go/.local/bin:${PATH}"
ENTRYPOINT ["tini-static", "--"]
CMD ["go-agent"]
