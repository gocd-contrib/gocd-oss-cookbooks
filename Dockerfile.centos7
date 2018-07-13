FROM centos:7
MAINTAINER GoCD Team <go-cd-dev@googlegroups.com>

COPY provision /usr/local/src/provision/

RUN /usr/local/src/provision/provision.sh

ENTRYPOINT ["/usr/bin/tini", "--"]

USER go

CMD ["/bin/bash", "-lc", "/bootstrap.sh"]
