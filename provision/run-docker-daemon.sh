#!/bin/bash
$(which dind) dockerd --host=unix:///var/run/docker.sock > /var/log/dockerd.log 2>&1 &
disown