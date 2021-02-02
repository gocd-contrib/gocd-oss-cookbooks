#!/bin/bash

PRIMARY_USER="go"

# import functions
source "$(dirname $0)/common.sh"

function provision() {
  step setup_apt_external_repos
  step upgrade_os_packages

  step install_basic_utils
  step install_native_build_packages

  step add_gocd_user

  step install_scm_tools

  step install_rbenv
  step install_global_ruby "3.0.0"

  step install_nodenv
  step install_global_node "15.7.0"
  step install_yarn

  step install_jabba
  step install_jdks "11" "12" "13" "14" "15"
  step default_jdk "15"

  step install_python
  step install_awscli

  step setup_nexus_configs

  step add_golang_gocd_bootstrapper
  step setup_entrypoint
  step install_tini

  step list_installed_packages
  step clean

  step print_versions_summary
}

function update_apt_cache() {
  try apt-get update
}

function setup_apt_external_repos() {
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
  try apt-get install -y debsigs gnupg gnupg-agent dpkg-sig apt-utils bzip2 gzip unzip zip sudo curl wget jq
}

function install_python() {
  try apt-get install -y python python3-pip
  try pip3 install --upgrade pip
}

function install_native_build_packages() {
  try apt-get install -y build-essential zlib1g-dev libcurl4 libssl-dev
}

function install_scm_tools() {
  try apt-get install -y git subversion
  setup_git_config
}

function install_awscli() {
  # `/etc/mime.types` is required by aws cli so it can generate appropriate `content-type` headers when uploading to s3. Without this file, all files in s3 will have content type `application/octet-stream`
  try apt-get install -y mime-support
  try pip3 install awscli
}

function clean() {
  try apt-get clean
  try rm -rf /usr/local/src/*
}

provision
