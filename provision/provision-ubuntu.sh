#!/bin/bash

PRIMARY_USER="go"

# import functions
source "$(dirname $0)/provision-common.sh"

function provision() {
  step setup_external_repos
  step upgrade_os_packages

  step install_basic_utils
  step install_native_build_packages

  step add_gocd_user

  # git, in particular, is used in subsequent provisioning so do this before things like `mise`
  step install_scm_tools

  step install_mise_tools \
    "java@temurin-21.0.8+9.0.LTS" \
    "ruby@3.4.6" \
    "node@22.20.0"
  step install_ruby_default_gems
  step install_yarn

  step install_awscli_mimetypes
  step install_awscli

  step setup_nexus_configs

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
  DEBIAN_FRONTEND=noninteractive try apt-get -y install software-properties-common
  try bash -c "yes | add-apt-repository ppa:git-core/ppa"
  update_apt_cache
}

function upgrade_os_packages() {
  try apt-get upgrade -y
}

function list_installed_packages() {
  try bash -c "dpkg -l"
}

function install_basic_utils() {
  try apt-get install -y debsigs gnupg gnupg-agent apt-utils bzip2 gzip unzip zip sudo curl wget jq
}

function install_native_build_packages() {
  # Ruby-build dependencies for mise: https://github.com/rbenv/ruby-build/wiki#ubuntudebianmint
  # Also see https://docs.ruby-lang.org/en/3.3/contributing/building_ruby_md.html
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
