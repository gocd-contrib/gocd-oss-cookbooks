#!/bin/bash

PRIMARY_USER="go"
GRADLE_OPTIONS="--stacktrace --no-daemon"

for arg in $@; do
  case $arg in
    --contrib)
      PRIMARY_USER="dojo"
      SKIP_INTERNAL_CONFIG="yes"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

NSIS_VERSION=3.10-1.el9 # https://nsis.sourceforge.io/Docs/AppendixF.html / https://github.com/gocd/nsis-rpm/tree/gh-pages/rpms
MAVEN_VERSION=3.9.9 # https://maven.apache.org/docs/history.html
ANT_VERSION=1.10.15 # https://ant.apache.org/bindownload.cgi
P4_VERSION=24.1 # https://cdist2.perforce.com/perforce/
P4D_VERSION=24.1

CENTOS_MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f4 | cut -d"." -f1)
# import functions
source "$(dirname $0)/provision-common.sh"

# Main entrypoint
function provision() {
  step setup_external_repos
  step upgrade_os_packages

  # these are build prereqs for subsequent things; install
  # these early during provision
  step install_basic_utils
  step install_native_build_packages

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    # setup gocd user to use internal mirrors for builds
    step add_gocd_user
  fi

  # git, in particular, is used in subsequent provisioning so do this before things like `mise`
  step install_scm_tools

  step install_mise_tools \
    "java@temurin-21.0.4+7.0.LTS" \
    "ruby@3.3.4" \
    "node@22.7.0"
  step install_ruby_default_gems
  step install_yarn

  step install_maven "$MAVEN_VERSION"
  step install_ant "$ANT_VERSION"

  step install_gauge
  step install_installer_tools
  step install_awscli_mimetypes
  step install_awscli

  step setup_postgres_repo # See https://endoflife.date/postgresql
  step install_postgresql "13"
  step install_postgresql "14"
  step install_postgresql "15"
  step install_postgresql "16"

  step install_geckodriver
  step install_firefox_dependencies
  step install_firefox_latest

  # On Docker for Mac, make sure you allocate more than 2G of memory or
  # gradle might randomly fail; 6G should be fairly reliable.
  if [ "${BUILDARCH}" == "${TARGETARCH}" ]; then
    # only do a pre-build to cache dependencies when not cross-compiling
    step build_gocd
  fi

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    step install_docker
    step install_regctl
    step setup_nexus_configs
    step add_golang_gocd_bootstrapper
  fi

  step install_tini

  step list_installed_packages
  step clean

  step print_versions_summary
}

function setup_epel() {
  try dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${CENTOS_MAJOR_VERSION}.noarch.rpm
}

function setup_external_repos() {
  try echo 'fastestmirror=1' >> /etc/dnf/dnf.conf
  try echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf

  setup_epel

  try dnf -y install "dnf-command(config-manager)"
  try dnf config-manager --set-enabled crb
}

function install_basic_utils() {
  try dnf -y install procps ncurses file which bzip2 gzip unzip zip sudo curl-minimal wget jq
}

function install_native_build_packages() {
  # Core stuff
  try dnf -y install autoconf automake make patch

  # Ruby-build dependencies for Mise: https://github.com/rbenv/ruby-build/wiki#rhelcentos
  # Also see https://docs.ruby-lang.org/en/3.3/contributing/building_ruby_md.html
  try dnf -y install autoconf gcc patch bzip2 openssl-devel libyaml-devel zlib-devel
}

function install_scm_tools() {
  install_git
  try dnf -y install mercurial
  try dnf -y install subversion

  try git --version
  try hg --version
  try svn --version

  if [ "$(arch)" == "x86_64" ]; then
    try mkdir -p /usr/local/bin
    try curl --silent --fail --location "https://cdist2.perforce.com/perforce/r${P4_VERSION}/bin.linux26x86_64/p4" --output /usr/local/bin/p4
    try curl --silent --fail --location "https://cdist2.perforce.com/perforce/r${P4D_VERSION}/bin.linux26x86_64/p4d" --output /usr/local/bin/p4d
    try chmod 755 /usr/local/bin/p4 /usr/local/bin/p4d
    try p4 -V
    try p4d -V
  fi
}

function install_git() {
  try dnf -y install git-core

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    setup_git_config
  fi
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

function setup_postgres_repo() {
  try dnf -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-$CENTOS_MAJOR_VERSION-$(arch)/pgdg-redhat-repo-latest.noarch.rpm
}

function install_postgresql() {
  local pg_version="$1"
  package_suffix="$(printf "${pg_version}" | sed -e 's/\.//g')"
  try dnf -y install postgresql${package_suffix} postgresql${package_suffix}-server postgresql${package_suffix}-contrib
}

function install_firefox_dependencies() {
  # install just the FF dependencies, without FF
  # shellcheck disable=SC2046
  try dnf -y install $(dnf deplist -y --arch "$(arch)" --latest-limit=1 firefox | awk '/provider:/ {print $2}' | sort -u)
}

function install_firefox_latest() {
  if [ "$(arch)" == "x86_64" ]; then
    # latest versions of FF
    try mkdir -p /opt/local/firefox
    try mkdir -p /opt/local/firefox-latest
    try curl --silent --fail --location 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US' --output /usr/local/src/firefox-latest.tar.bz2
    try tar -jxf /usr/local/src/firefox-latest.tar.bz2 -C /opt/local/firefox-latest --strip-components=1

    try ln -sf /opt/local/firefox-latest/firefox /usr/local/bin/firefox
    try /opt/local/firefox-latest/firefox -version
  else
    # Install latest official LTS/ESR release that is available for the platform
    try dnf -y install firefox
  fi
  try firefox -version
}

function list_installed_packages() {
  try bash -c "rpm -qa | sort"
}

function clean() {
  try dnf clean all
  try rm -rf /var/cache/dnf
  try rm -rf /usr/local/src/*
}

function upgrade_os_packages() {
  try dnf -y upgrade --quiet
}

function build_gocd() {
  if [ "$(how_much_memory_in_gb)" -lt 6 ]; then
    yellowalert "                                                                                "
    yellowalert "////////////////////////////////////////////////////////////////////////////////"
    yellowalert "////                                Warning!                                ////"
    yellowalert "////////////////////////////////////////////////////////////////////////////////"
    yellowalert "                                                                                "
    yellowalert "Your Docker container has less than 6GB of RAM allocated. Building the GoCD     "
    yellowalert "codebase may intermittently fail. For best results, allocate AT LEAST 4G of RAM "
    yellowalert "to this container.                                                              "
    yellowalert "                                                                                "
    yellowalert "No, really. In fact, I'd recommend 6G to be safe.                               "
    yellowalert "                                                                                "
    yellowalert "As Biggie once said: \"Mo' RAM, fewer problems...\"                               "
    yellowalert "                                                                                "
    yellowalert "  (he didn't really say that)                                                   "
    yellowalert "                                                                                "
    printf "\n"
  fi

  try su - ${PRIMARY_USER} -c "git clone --depth 1 https://github.com/gocd/gocd /tmp/gocd && \
              cd /tmp/gocd && \
              mise install && \
              ./gradlew compileAll yarnInstall --no-build-cache --max-workers 4 --quiet ${GRADLE_OPTIONS}"
  try rm -rf /tmp/gocd /${PRIMARY_USER}/.gradle/caches/build-cache-*
}

function install_docker() {
  try dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  try dnf -y install docker-ce containerd.io docker-buildx-plugin
  try usermod -a -G docker ${PRIMARY_USER}
}

function install_regctl() {
  local arch="$(if [ "$(arch)" == "x86_64" ]; then echo "amd64"; else echo "arm64"; fi)"
  try mkdir -p /usr/local/bin
  try curl --silent --fail --location "https://github.com/regclient/regclient/releases/latest/download/regctl-linux-${arch}" --output /usr/local/bin/regctl
  try chmod 755 /usr/local/bin/regctl
  try regctl version
}

provision
