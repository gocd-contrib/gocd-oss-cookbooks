#!/bin/bash

set -e

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
  setup_gradle_config
  setup_maven_config
  setup_rubygems_config
  setup_npm_config
}

function setup_gradle_config() {
  copy_to_home_dir init.gradle .gradle/init.gradle
}

function setup_maven_config() {
  copy_to_home_dir settings.xml .m2/settings.xml
}

function setup_rubygems_config() {
  copy_to_home_dir bundle-config .bundle/config
}

function setup_npm_config() {
  copy_to_home_dir npmrc .npmrc
}

function setup_git_config() {
  copy_to_home_dir gitconfig .gitconfig
}

# devtools

# Install multi-tool version manager mise: https://mise.jdx.dev/
function install_mise_tools() {
  try su - "${PRIMARY_USER:-go}" -c "curl https://mise.jdx.dev/install.sh | sh"
  try su - "${PRIMARY_USER:-go}" -c "mise -v && ASFLAGS=\"-mbranch-protection=pac-ret\" mise use --global ${*}"
  try su - "${PRIMARY_USER:-go}" -c "echo \"export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"\" >> ~/.bash_profile"
}

function install_ruby_default_gems() {
  try su - "${PRIMARY_USER:-go}" -c "gem install rake --no-document && rake --version"
}

function install_yarn() {
  try su - "${PRIMARY_USER:-go}" -c "corepack enable && mise reshim && yarn --version"
}

function install_gauge() {
  local version="$1"
  local arch="$(if [ "$(arch)" == "x86_64" ]; then echo "x86_64"; else echo "arm64"; fi)"
  try curl --silent --fail --location "https://github.com/getgauge/gauge/releases/download/v$version/gauge-$version-linux.$arch.zip" --output /usr/local/src/gauge.zip
  try unzip -d /usr/bin /usr/local/src/gauge.zip

  for plugin in ruby html-report screenshot; do
    try su - "$PRIMARY_USER" -c "gauge install ${plugin}"
  done

  try su - "$PRIMARY_USER" -c "gauge -v"
}

function install_awscli() {
  try curl --silent --fail --location "https://awscli.amazonaws.com/awscli-exe-linux-$(arch).zip" --output "/tmp/awscliv2.zip"
  try unzip -q /tmp/awscliv2.zip
  try ./aws/install
  try rm -rf /aws /tmp/awscliv2.zip
}

function install_maven() {
  local version="$1"
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/maven/maven-3/${version}/binaries/apache-maven-${version}-bin.zip --output /usr/local/src/apache-maven-${version}-bin.zip
  try unzip -q /usr/local/src/apache-maven-${version}-bin.zip -d /opt/local
  try ln -sf /opt/local/apache-maven-${version}/bin/mvn /usr/local/bin/mvn
}

function install_ant() {
  local version="$1"
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/ant/binaries/apache-ant-${version}-bin.zip --output /usr/local/src/apache-ant-${version}-bin.zip
  try unzip -q /usr/local/src/apache-ant-${version}-bin.zip -d /opt/local
  try ln -sf /opt/local/apache-ant-${version}/bin/ant /usr/local/bin/ant
}

function install_geckodriver() {
  local arch="$(if [ "$(arch)" == "x86_64" ]; then echo "linux64"; else echo "linux-aarch64"; fi)"
  local URL="$(curl --silent --fail --location https://github-api-proxy.gocd.org/repos/mozilla/geckodriver/releases/latest | jq -r ".assets[] | select(.name | endswith(\"$arch.tar.gz\")) | .browser_download_url")"
  try curl --silent --fail --location "${URL}" --output /usr/local/src/geckodriver-latest.tar.gz
  try tar -zxf /usr/local/src/geckodriver-latest.tar.gz -C /usr/local/bin
}

# startup services

function install_tini() {
  local arch="$(if [ "$(arch)" == "x86_64" ]; then echo "amd64"; else echo "arm64"; fi)"
  local URL="$(curl --silent --fail --location https://github-api-proxy.gocd.org/repos/krallin/tini/releases/latest | jq -r ".assets[] | select(.name | endswith(\"-static-$arch\")) | .browser_download_url" | grep -v muslc)"
  try curl -fsSL --output /usr/bin/tini "$URL"
  try chmod a+rx /usr/bin/tini
  try tini --version
}

function add_golang_gocd_bootstrapper() {
  local arch="$(if [ "$(arch)" == "x86_64" ]; then echo "amd64"; else echo "arm64"; fi)"
  local URL="$(curl -fsSL https://github-api-proxy.gocd.org/repos/gocd-contrib/gocd-golang-bootstrapper/releases/latest | jq -r ".assets[] | select(.name | endswith(\"linux.$arch\")) | .browser_download_url")"
  try curl -fsSL --output /go/go-agent "${URL}"
  try chown go:go /go/go-agent
  try chmod a+rx /go/go-agent
}

# helpers

function print_versions_summary() {
  green "$(try su - "${PRIMARY_USER:-go}" <<-EOF
printf "\n"
printf "//////////////////////////////\n"
printf "// Package versions summary //\n"
printf "//////////////////////////////\n"
printf "\n"

printf "git version:\n"
git --version | pr -to 2
printf "\n"

printf "ruby version:\n"
ruby --version | pr -to 2
printf "\n"

printf "node version:\n"
node --version | pr -to 2
printf "\n"

printf "yarn version:\n"
yarn --version | pr -to 2
printf "\n"

printf "aws version:\n"
aws --version | pr -to 2
printf "\n"

printf "Installed JDKs:\n"
mise list java
printf "\n"

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

function how_much_memory_in_gb() {
  free -t -g | grep -F Total: | awk '{print $2}'
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
