#!/bin/bash

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { echo "$ $@" 1>&2; "$@" || die "cannot $*"; }

CENTOS_MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3 | cut -d"." -f1)

if [ "$CENTOS_MAJOR_VERSION" -ge "7" ]; then
  # since we do not install X and FF on centos 6
  export DISPLAY=:3
  try Xvfb :3 -screen 0 1280x960x16 &
fi

try exec /go/go-agent
