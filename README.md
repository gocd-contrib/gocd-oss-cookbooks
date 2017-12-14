#### Images built:

- `gocddev/gocd-dev-build:centos-6-pg9.2-<github_tag>`
- `gocddev/gocd-dev-build:centos-6-pg9.3-<github_tag>`
- `gocddev/gocd-dev-build:centos-6-pg9.4-<github_tag>`
- `gocddev/gocd-dev-build:centos-6-pg9.5-<github_tag>`
- `gocddev/gocd-dev-build:centos-6-pg9.6-<github_tag>`
- `gocddev/gocd-dev-build:centos-6-<github_tag>`

- `gocddev/gocd-dev-build:centos-7-pg9.2-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-pg9.3-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-pg9.4-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-pg9.5-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-pg9.6-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-<github_tag>`


#### Build all images locally

- Run SOURCE_BRANCH=value `hooks/build.sh`

SOURCE_BRANCH is an env var provided by docker cloud for automated builds.

#### Build a specific image locally

- Replace `__PG_VERSION__` in solo-centos6.json or solo-centos7.json with the postgres version of your choice.
- Run `docker build -f <Dockerfile.centos6 | Dockerfile.centos7> . -t <image_name>`