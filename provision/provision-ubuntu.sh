#!/usr/bin/env bash

PRIMARY_USER="go"

# import functions
source "$(dirname $0)/provision-common.sh"

function provision() {
  export DEBIAN_FRONTEND=noninteractive

  step upgrade_os_packages

  step install_basic_utils

  step add_gocd_user
  step setup_nexus_configs

  # git, in particular, is used in subsequent provisioning so do this before things like `mise`
  step install_scm_tools
  step install_mise_tools "mise-ubuntu.toml"
  step install_awscli_mimetypes

  step list_installed_packages
  step print_versions_summary

  step clean
}

function upgrade_os_packages() {
  try apt-get update
  try apt-get upgrade -y
}

function list_installed_packages() {
  try bash -c "dpkg -l"
}

function install_basic_utils() {
  try apt-get install -y debsigs gnupg gnupg-agent apt-utils bzip2 gzip unzip zip sudo curl wget jq locales
  try bash -c "echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen"
}

function install_scm_tools() {
  try apt-get install -y git
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
  try rm -rf /${PRIMARY_USER}/.cache
}

provision
