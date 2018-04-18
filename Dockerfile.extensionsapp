FROM gocd/gocd-agent-docker-dind:v18.2.0
MAINTAINER GoCD Team <go-cd-dev@googlegroups.com>

RUN apk add --no-cache python3 groff && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache && \
    pip install awscli