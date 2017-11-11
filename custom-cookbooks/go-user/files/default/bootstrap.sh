#!/bin/bash

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { echo "$ $@" 1>&2; "$@" || die "cannot $*"; }

export DISPLAY=:3

OS_VERSION="$(lsb_release -a | grep Release | cut -f2 | cut -f1 -d.)"

if [ OS_VERSION == "6" ]; then
  try sudo /etc/init.d/messagebus start
fi

try vncserver :3 -geometry '1280x960' -depth 16
try exec /go/go-agent
