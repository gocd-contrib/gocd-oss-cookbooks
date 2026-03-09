#!/usr/bin/env bash

#####################################################################
# These are functions shared by both CentOS and Ubuntu provisioners #
#####################################################################

function validate_sourced() {
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    die "${BASH_SOURCE[0]} is intended to be sourced as a library";
  fi
}

# user setup

function add_gocd_user() {
  try useradd --create-home --home-dir /go --shell /bin/bash go
  try cp /usr/local/src/provision/gocd-sudoers /etc/sudoers.d/go
  try chmod 0440 /etc/sudoers.d/go
}

function setup_nexus_configs() {
  if [ "${SKIP_INTERNAL_CONFIG:-}" != "yes" ]; then
    copy_to_home_dir init.gradle   .gradle/init.gradle
    copy_to_home_dir settings.xml  .m2/settings.xml
    copy_to_home_dir bundle-config .bundle/config
    copy_to_home_dir npmrc         .npmrc
    copy_to_home_dir yarnrc.yml    .yarnrc.yml
  fi
}

function setup_git_config() {
  if [ "${SKIP_INTERNAL_CONFIG:-}" != "yes" ]; then
    copy_to_home_dir gitconfig .gitconfig
  fi
}

# Install multi-tool version manager mise: https://mise.jdx.dev/
function install_mise_tools() {
  copy_to_home_dir "${1}" .config/mise/config.toml
  try su - "${PRIMARY_USER}" -c "curl https://mise.run | sh"
  try su - "${PRIMARY_USER}" -c "mise settings ruby.compile=false && GITHUB_TOKEN=\$(cat /run/secrets/github_token) CLICOLOR_FORCE=1 mise install"
  try su - "${PRIMARY_USER}" -c "echo 'export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"' | tee -a ~/.bashrc ~/.profile"
  try su - "${PRIMARY_USER}" -c "ln -s ~/.local/share/mise ~/.asdf" # Workaround lack of Gradle support for discovering mise toolchains https://github.com/gradle/gradle/issues/29355
}

# helpers

function print_versions_summary() {
  green "$(try su - "${PRIMARY_USER}" <<-EOF
printf "\n"
printf "//////////////////////////////\n"
printf "// Package versions summary //\n"
printf "//////////////////////////////\n"
printf "\n"

printf "mise summary:\n"
mise list | pr -to 2
printf "\n"

printf "git version:\n"
git --version | pr -to 2
printf "\n"

printf "aws version:\n"
aws --version | pr -to 2
printf "\n"

printf "ruby version:\n"
ruby --version | pr -to 2
printf "\n"

if type node &> /dev/null; then
  printf "node version:\n"
  node --version | pr -to 2
  printf "\n"
fi

if type yarn &> /dev/null; then
  printf "yarn version:\n"
  yarn --version | pr -to 2
  printf "\n"
fi

if type gauge &> /dev/null; then
  printf "gauge version:\n"
  gauge -v | pr -to 2
  printf "\n"
fi

EOF
)"
}

function copy_to_home_dir() {
  local src="$1"
  local dst="$2"
  local destdir="$(dirname "$dst")"
  local provisiondir="$(dirname $0)"
  local homedir="$(eval printf "%s" "~go")" # expand ~go to abs path

  if [ "$destdir" != "." ]; then
    try mkdir -p "$homedir/$destdir"
  fi

  try cp "$provisiondir/$src" "$homedir/$dst"
  try chown go:go -R "$homedir"
}

# output and control

function yell() { redalert "$0: $*" >&2; }
function die() { yell "$*"; exit 111; }
function try() { magenta "\$ $@" >&2; "$@" || die "Failed to execute: \`$*\`"; }
function step() {
  printf "\n\n" >&2
  cyan "////////////////////////////////////////////////////////////////////////////////" >&2
  cyan "  => Step: $*" >&2
  cyan "////////////////////////////////////////////////////////////////////////////////" >&2
  printf "\n\n" >&2
  "$@"
}

# colors

function redalert() { printf "\e[1;41m$*\e[0m\n"; }
function yellowalert() { printf "\e[1;43;37m$*\e[0m\n"; }
function cyan() { printf "\e[36;1m$*\e[0m\n"; }
function magenta() { printf "\e[35;1m$*\e[0m\n"; }
function green() { printf "\e[32;1m$*\e[0m\n"; }

validate_sourced
