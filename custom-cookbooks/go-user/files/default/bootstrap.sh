#!/bin/bash

export DISPLAY=:3

sudo /etc/init.d/messagebus start && \
  vncserver :3 -geometry '1280x960' -depth 16 && \
  exec /go/go-agent
