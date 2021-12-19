#!/bin/bash

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { echo "$ $@" 1>&2; "$@" || die "cannot $*"; }

export DISPLAY=:3
try Xvfb :3 -screen 0 1280x960x16 &

try exec /go/go-agent
