#!/usr/bin/env bash

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { echo "$ $@" 1>&2; "$@" || die "cannot $*"; }

PRIMARY_USER="go"

function update_apt_cache() {
  try apt-get update
}

function upgrade_os_packages() {
  try apt-get upgrade -y
}

function list_installed_packages() {
  try bash -c "dpkg -l"
}

function install_basic_utils() {
  try apt-get install -y debsigs gnupg gnupg-agent dpkg-sig apt-utils bzip2 gzip unzip zip sudo curl wget jq
}

function install_ruby() {
  try apt-get install -y ruby ruby-ffi ruby-dev ruby-bundler
}

function install_python() {
  try apt-get install -y python python-pip
}

function install_node() {
  try bash -c "curl -sL https://deb.nodesource.com/setup_10.x | bash -"
  try apt-get update
  try apt-get install -y nodejs
}

function install_yarn() {
  try bash -c "curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -"
  try bash -c "echo deb https://dl.yarnpkg.com/debian/ stable main| sudo tee /etc/apt/sources.list.d/yarn.list"
  try apt-get update
  try apt-get install -y yarn
}

function install_jabba() {
  try su - ${PRIMARY_USER} -c 'curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash'
}

function install_jdk11() {
  try su - ${PRIMARY_USER} -c "jabba install openjdk@1.11"
}

function install_jdk12() {
  try su - ${PRIMARY_USER} -c "jabba install openjdk@1.12"
}

function install_jdk13() {
  try su - ${PRIMARY_USER} -c "jabba install openjdk@1.13.0"
}

function install_native_build_packages() {
  try apt-get install -y build-essential zlib1g-dev libcurl3
}

function install_scm_tools() {
  try apt-get install -y git subversion
}

function add_gocd_user() {
  try useradd --create-home --home-dir /go --shell /bin/bash go
  try cp /usr/local/src/provision/gocd-sudoers /etc/sudoers.d/go
  try chmod 0440 /etc/sudoers.d/go
}

function setup_git_config() {
  try cp /usr/local/src/provision/gitconfig /go/.gitconfig
  try chown go:go /go/.gitconfig
}

function setup_gradle_config() {
  try mkdir -p /go/.gradle/
  try cp /usr/local/src/provision/init.gradle /go/.gradle/init.gradle
  try chown go:go -R /go/.gradle
}

function setup_maven_config() {
  try mkdir -p /go/.m2/
  try cp /usr/local/src/provision/settings.xml /go/.m2/settings.xml
  try chown go:go -R /go/.m2
}

function setup_rubygems_config() {
  try mkdir -p /go/.bundle/
  try cp /usr/local/src/provision/bundle-config /go/.bundle/config
  try chown go:go -R /go/.bundle
}

function setup_npm_config() {
  try mkdir -p /go/.bundle/
  try cp /usr/local/src/provision/npmrc /go/.npmrc
  try chown go:go -R /go/.npmrc
}

function add_golang_gocd_bootstrapper() {
  URL="$(curl --silent --fail --location https://api.github.com/repos/ketan/gocd-golang-bootstrapper/releases/latest | jq -r '.assets[] | select(.name | contains("linux.amd64")) | .browser_download_url')"
  try curl --silent --fail --location "${URL}" --output /go/go-agent
  try chown go:go /go/go-agent
  try chmod 755 /go/go-agent
}

function setup_entrypoint() {
  try cp /usr/local/src/provision/with-java /usr/local/bin/with-java
  try cp /usr/local/src/provision/bootstrap.sh /bootstrap.sh
  try chmod 755 /usr/local/bin/with-java
  try chmod 755 /bootstrap.sh
}

function install_tini() {
  URL="$(curl --silent --fail --location https://api.github.com/repos/krallin/tini/releases/latest | jq -r '.assets[] | select(.name | match("-amd64.deb$")) | .browser_download_url' | grep -v muslc)"
  try curl --fail --silent --location "${URL}" -o /usr/local/src/tini.deb
  try dpkg -i /usr/local/src/tini.deb
  try tini --version
  try rm /usr/local/src/tini.deb
}

function install_awscli() {
  # `/etc/mime.types` is required by aws cli so it can generate appropriate `content-type` headers when uploading to s3. Without this file, all files in s3 will have content type `application/octet-stream`
  try apt-get install -y mime-support
  try pip install awscli
}


function clean() {
  try rm -rf /usr/local/src/*
}

update_apt_cache
upgrade_os_packages

install_basic_utils
add_gocd_user
install_node
install_yarn
install_native_build_packages
install_ruby
install_python
install_awscli
install_scm_tools

setup_git_config

setup_gradle_config
setup_maven_config
setup_rubygems_config
setup_npm_config

install_jabba
install_jdk11
install_jdk12
install_jdk13

add_golang_gocd_bootstrapper
setup_entrypoint
install_tini

list_installed_packages
clean
