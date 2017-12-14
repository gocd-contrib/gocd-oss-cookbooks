#!/usr/bin/env bash

pg_versions=('9.2' '9.3' '9.4' '9.5' '9.6')
for pg_version in ${pg_versions}; do
sed -i '' "s/__PG_VERSION__/$pg_version/g" solo-centos6.json
sed -i '' "s/__PG_VERSION__/$pg_version/g" solo-centos7.json
docker build -f Dockerfile.centos6 . -t gocddev/gocd-dev-build:centos-6-pg"$pg_version"-"$SOURCE_BRANCH"
docker build -f Dockerfile.centos7 . -t gocddev/gocd-dev-build:centos-7-pg"$pg_version"-"$SOURCE_BRANCH"
done

docker tag gocddev/gocd-dev-build:centos-6-pg9.6-"$SOURCE_BRANCH" gocddev/gocd-dev-build:centos-6-"$SOURCE_BRANCH"
docker tag gocddev/gocd-dev-build:centos-7-pg9.6-"$SOURCE_BRANCH" gocddev/gocd-dev-build:centos-7-"$SOURCE_BRANCH"
