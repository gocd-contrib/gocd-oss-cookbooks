FROM almalinux:10
LABEL org.opencontainers.image.authors="GoCD Team <go-cd-dev@googlegroups.com>"

COPY provision       /usr/local/src/provision/
COPY provision-linux /usr/local/src/provision/

RUN --mount=type=secret,id=github_token,target=/run/secrets/github_token,mode=0444,required=true \
    /usr/local/src/provision/provision-rhelcompat.sh

# Create volume where the golang-gocd-bootstrapper will use as work dir
RUN mkdir -p /go-working-dir && chown go:go /go-working-dir
VOLUME /go-working-dir
USER go

# Mount a docker volume to improve performance and reduce change of storage issues with dind-in-dind
# https://github.com/docker-library/docker/blob/319e58aa0299128924649f0745054a1b8732545a/29/dind/Dockerfile#L104
VOLUME /var/lib/docker

# force encoding
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV PATH="/go/.local/share/mise/shims:/go/.local/bin:${PATH}"
ENTRYPOINT ["tini", "--"]
CMD ["go-agent"]
