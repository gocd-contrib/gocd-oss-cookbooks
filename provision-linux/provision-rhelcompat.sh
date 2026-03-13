#!/usr/bin/env bash
set -euo pipefail

PRIMARY_USER="go"
GRADLE_OPTIONS="--stacktrace --no-daemon"

for arg in $@; do
  case $arg in
    --contrib)
      SKIP_INTERNAL_CONFIG="yes"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

NSIS_VERSION=3.11-1.el9 # https://nsis.sourceforge.io/Docs/AppendixF.html / https://github.com/gocd/nsis-rpm/tree/gh-pages/rpms
P4_VERSION=25.2         # https://cdist2.perforce.com/perforce/
P4D_VERSION=25.2
DOCKER_VERSION=29       # https://download.docker.com/linux/rhel/10/x86_64/stable/Packages/

RHEL_COMPAT_MAJOR_VERSION=$(rpm -qa \*-release | grep -oiP "(oracle|redhat|centos|alma|rocky).*-release-\K[0-9]+")
# import functions
source "$(dirname $0)/provision-common.sh"

# Main entrypoint
function provision() {
  step upgrade_os_packages

  # these are build prereqs for subsequent things; install
  # these early during provision
  step install_basic_utils
  step install_native_build_packages

  step add_gocd_user
  step setup_nexus_configs

  # git, in particular, is used in subsequent provisioning so do this before things like `mise`
  step install_scm_tools
  step mise_install_globally "mise-rhelcompat.toml"
  step install_awscli_mimetypes

  step install_installer_tools

  # For functional tests
  step install_postgresql "15" "16" "17" "18"
  step install_firefox

  if [ "${SKIP_INTERNAL_CONFIG:-}" != "yes" ]; then
    step install_docker
  fi

  step list_installed_packages
  step print_versions_summary

  step cache_gocd_dependencies
  step clean
}

function install_basic_utils() {
  try dnf -y install procps gnupg2 ncurses file which xz bzip2 gzip unzip zip sudo curl-minimal wget jq glibc-langpack-en
}

function install_native_build_packages() {
  # Core stuff
  try dnf -y install autoconf automake make patch gcc
}

function install_scm_tools() {
  try dnf -y install git-core mercurial subversion
  setup_git_config

  try git --version
  try hg --version
  try svn --version

  try mkdir -p /usr/local/bin
  try curl --silent --fail --location "https://cdist2.perforce.com/perforce/r${P4_VERSION}/bin.linux26$(arch)/p4" --output /usr/local/bin/p4
  try curl --silent --fail --location "https://cdist2.perforce.com/perforce/r${P4D_VERSION}/bin.linux26$(arch)/p4d" --output /usr/local/bin/p4d
  try chmod 755 /usr/local/bin/p4 /usr/local/bin/p4d
  try p4 -V
  try p4d -V
}

function install_installer_tools() {
  try dnf -y install \
      xz-lzma-compat \
      dpkg-devel dpkg-dev \
      createrepo yum-utils rpm-build rpm-sign fakeroot \
      gnupg2

  if [ "$(arch)" == "x86_64" ]; then
    try dnf -y install "http://gocd.github.io/nsis-rpm/rpms/mingw-nsis-base-${NSIS_VERSION}.$(arch).rpm"
    try dnf -y install "http://gocd.github.io/nsis-rpm/rpms/mingw64-nsis-${NSIS_VERSION}.noarch.rpm"
    try dnf -y install "http://gocd.github.io/nsis-rpm/rpms/mingw32-nsis-${NSIS_VERSION}.noarch.rpm"
  fi

  try su - "$PRIMARY_USER" -c "gem install fpm --no-document"
}

function install_awscli_mimetypes() {
  # `/etc/mime.types` is required by aws cli so it can generate appropriate `content-type` headers when uploading to s3.
  # Without this file, all files in s3 will have content type `application/octet-stream`
  # See https://github.com/aws/aws-cli/issues/1249
  try dnf -y install mailcap
}

function install_postgresql() {
  try dnf -y install "https://download.postgresql.org/pub/repos/yum/reporpms/EL-$RHEL_COMPAT_MAJOR_VERSION-$(arch)/pgdg-redhat-repo-latest.noarch.rpm"

  local pg_version
  local pkgs=()
  for pg_version in "$@"; do
    pkgs+=("postgresql${pg_version}" "postgresql${pg_version}-server" "postgresql${pg_version}-contrib")
  done

  try dnf -y install "${pkgs[@]}"
}

function install_firefox() {
  try dnf -y install firefox
  try firefox -version
}

function install_docker() {
  try dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
  try dnf -y install docker-ce-${DOCKER_VERSION}* containerd.io docker-buildx-plugin
  try usermod -a -G docker ${PRIMARY_USER}
}

function list_installed_packages() {
  try bash -c "rpm -qa | sort"
}

function clean() {
  try su - "${PRIMARY_USER}" -c "mise cache clear"
  try su - "${PRIMARY_USER}" -c "rm -rf ~/.cache"
  try dnf clean all
  try rm -rf /var/cache/dnf
  try rm -rf /usr/local/src/*
}

function upgrade_os_packages() {
  try echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf
  try dnf -y upgrade --quiet
  try dnf -y install epel-release
}

function cache_gocd_dependencies() {
  try su - ${PRIMARY_USER} -c "set -euo pipefail && \
    git clone --depth 1 https://github.com/gocd/gocd /tmp/gocd && \
    cd /tmp/gocd && \
    $(cmd_echo_mise_install_globally_from_local) && \
    ./gradlew resolveExternalDependencies compileAll --no-build-cache --quiet ${GRADLE_OPTIONS} && \
    ./gradlew --stop && \
    rm -rf /tmp/gocd"

  for bundle_repo in ruby-functional-tests codesigning; do
    try su - ${PRIMARY_USER} -c "set -euo pipefail && \
      git clone --depth 1 https://github.com/gocd/${bundle_repo} /tmp/${bundle_repo} && \
      cd /tmp/${bundle_repo} && \
      $(cmd_echo_mise_install_globally_from_local) && \
      bundle install && \
      rm -rf /tmp/${bundle_repo}"
  done
}

provision
