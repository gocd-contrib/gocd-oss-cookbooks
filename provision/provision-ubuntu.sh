#!/bin/bash

PRIMARY_USER="go"

# import functions
source "$(dirname $0)/provision-common.sh"

function provision() {
  export DEBIAN_FRONTEND=noninteractive

  step setup_external_repos
  step upgrade_os_packages

  step install_basic_utils
  step install_native_build_packages

  step add_gocd_user
  step setup_nexus_configs

  # git, in particular, is used in subsequent provisioning so do this before things like `mise`
  step install_scm_tools

  step install_mise_tools \
    "java@temurin-25" \
    "ruby@4.0" \
    "node@24"
  step install_ruby_default_gems
  step install_yarn

  step install_awscli_mimetypes
  step install_awscli

  step add_golang_gocd_bootstrapper
  step install_tini

  step list_installed_packages
  step clean

  step print_versions_summary
}

function update_apt_cache() {
  try apt-get update
}

function setup_external_repos() {
  update_apt_cache
}

function upgrade_os_packages() {
  try apt-get upgrade -y
}

function list_installed_packages() {
  try bash -c "dpkg -l"
}

function install_basic_utils() {
  try apt-get install -y debsigs gnupg gnupg-agent apt-utils bzip2 gzip unzip zip sudo curl wget jq locales
  try bash -c "echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen"
}

function install_native_build_packages() {
  # Ruby-build dependencies for mise: https://github.com/rbenv/ruby-build/wiki#ubuntudebianmint
  # Also see https://docs.ruby-lang.org/en/3.4/contributing/building_ruby_md.html
  try apt-get install -y autoconf patch build-essential libssl-dev libyaml-dev zlib1g-dev
}

function install_scm_tools() {
  try apt-get install -y git subversion
  setup_git_config
}

function install_awscli_mimetypes() {
  # `/etc/mime.types` is required by aws cli so it can generate appropriate `content-type` headers when uploading to s3.
  # Without this file, all files in s3 will have content type `application/octet-stream`
  # See https://github.com/aws/aws-cli/issues/1249
  try apt-get install -y media-types
}

function clean() {
  try apt-get clean
  try rm -rf /usr/local/src/*
}

provision
