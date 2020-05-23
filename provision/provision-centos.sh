#!/bin/bash

PRIMARY_USER="go"
GRADLE_OPTIONS="--stacktrace --info"

for arg in $@; do
  case $arg in
    --contrib)
      PRIMARY_USER="dojo"
      SKIP_INTERNAL_CONFIG="yes"
      GRADLE_OPTIONS="${GRADLE_OPTIONS} --no-daemon --max-workers 1"
      shift
      ;;
    *)
      shift
      ;;
  esac
done

NSIS_VERSION=3.04-2
MAVEN_VERSION=3.5.4
ANT_VERSION=1.10.4
P4_VERSION=15.1
P4D_VERSION=16.2
TINI_VERSION=0.18.0
POSTGRESQL_VERSION=9.6

CENTOS_MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)

# Main entrypoint
function provision() {
  setup_yum_external_repos

  # these are build prereqs for subsequent things; install
  # these early during provision
  install_basic_utils
  install_native_build_packages

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    # setup gocd user to use internal mirrors for builds
    add_gocd_user
  fi

  # git, in particular, is used in subsequent provisioning
  # so do this before things like `rbenv` and `nodenv`
  install_scm_tools

  install_rbenv
  install_global_ruby "2.7.1"

  install_nodenv
  install_global_node "14.3.0"
  install_yarn

  install_jabba
  install_jdks
  install_maven
  install_ant

  install_python

  install_gauge
  install_installer_tools
  install_awscli

  setup_postgres_repo
  install_postgresql "9.6"
  install_postgresql "10"
  install_postgresql "11"
  install_postgresql "12"

  install_sysvinit_tools

  if [ "$CENTOS_MAJOR_VERSION" == "7" ]; then
    install_geckodriver
    install_firefox_dependencies
    install_firefox_latest
    install_xvfb
    install_xss
    if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
      install_docker
    fi
  fi

  # on docker for mac, make sure you allocate more
  # than 2G of memoryor gradle might randomly fail
  build_gocd

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    setup_nexus_configs
  fi

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    add_golang_gocd_bootstrapper
    setup_entrypoint
  fi

  install_tini

  upgrade_os_packages
  list_installed_packages
  clean

  print_versions_summary
}

function print_versions_summary() {
  printf "Important package versions summary:\n\n"

  try su - "$PRIMARY_USER" <<-EOF
echo "git version:"
git --version

echo "ruby version:"
ruby --version

echo "node version:"
node --version

echo "yarn version:"
yarn --version

echo "Installed JDKs:"
jabba ls

echo "gauge version:"
gauge -v
EOF
}
function setup_epel() {
  try yum -y install epel-release
}

# Software Collections Library yum repo
# For recent-ish versions of `gcc` + friends
function setup_scl() {
  try yum -y install centos-release-scl
}

# https://ius.io/ - Inline with Upstream Stable yum repo
# For modern versions of `git`
function setup_ius() {
  try yum -y install \
    "https://repo.ius.io/ius-release-el${CENTOS_MAJOR_VERSION}.rpm" \
    "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${CENTOS_MAJOR_VERSION}.noarch.rpm"
}

function setup_yum_external_repos() {
  setup_epel
  setup_ius
  setup_scl
}

function install_basic_utils() {
  # add some basic utils
  try yum install --assumeyes \
      ncurses \
      file \
      wget \
      curl \
      zip \
      unzip \
      tar \
      gzip \
      bzip2 \
      which \
      sudo

  try curl --silent --fail --location https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 --output /usr/local/bin/jq
  try chmod 755 /usr/local/bin/jq
}

function install_rbenv() {
  # in case this exists, remove it; the installer will try to symlink this into ~go/.rbenv/versions
  try rm -rf /opt/rubies

  cat <<-EOF > /etc/profile.d/rbenv.sh
export PATH="\$HOME/.rbenv/bin:\$PATH"
if command -v rbenv &> /dev/null; then
  eval "\$(rbenv init -)"
fi
EOF
  try su - "$PRIMARY_USER" -c "bash /usr/local/src/provision/rbenv-installer"
  try su - "$PRIMARY_USER" -c "git -C \"\$(rbenv root)/plugins\" clone https://github.com/tpope/rbenv-aliases"

  echo "Validating rbenv installation"
  try su - "$PRIMARY_USER" -c "curl -fsSL https://raw.githubusercontent.com/rbenv/rbenv-installer/master/bin/rbenv-doctor | bash"
}

function install_nodenv() {
  # in case this exists, remove it; the installer will try to symlink this into ~go/.nodenv/versions; and yes,
  # even though this is nodenv and not rbenv...
  try rm -rf /opt/rubies

  cat <<-EOF > /etc/profile.d/nodenv.sh
export PATH="\$HOME/.nodenv/bin:\$PATH"
if command -v nodenv &> /dev/null; then
  eval "\$(nodenv init -)"
fi
EOF
  try su - "$PRIMARY_USER" -c "bash /usr/local/src/provision/nodenv-installer"
  try su - "$PRIMARY_USER" -c "git -C \"\$(nodenv root)/plugins\" clone https://github.com/nodenv/node-build-update-defs"
  try su - "$PRIMARY_USER" -c "git -C \"\$(nodenv root)/plugins\" clone https://github.com/nodenv/nodenv-aliases"

  echo "Validating nodenv installation"
  try su - "$PRIMARY_USER" -c "curl -fsSL https://raw.githubusercontent.com/nodenv/nodenv-installer/master/bin/nodenv-doctor | bash"
}

function install_jabba() {
  try su - ${PRIMARY_USER} -c 'curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash'
}

function major_minor() {
  local version="$1"
  printf "$(printf $version | cut -d. -f1).$(printf $version | cut -d. -f2)"
}

function install_global_ruby() {
  local version="$1"
  try su - "$PRIMARY_USER" -c "rbenv install $version && rbenv global $(major_minor $version) && echo \"Default ruby version: \$(ruby --version)\""
  try su - "$PRIMARY_USER" -c "gem install rake bundler && rbenv rehash && rake --version && bundle --version"
}

function install_global_node() {
  local version="$1"
  try su - "$PRIMARY_USER" -c "nodenv install $version && nodenv global $(major_minor $version) && echo \"Default node version: \$(node --version)\""
}

function install_yarn() {
  try su - "$PRIMARY_USER" -c "npm install -g yarn && nodenv rehash && yarn --version"
}

function install_gauge() {
    cat <<-EOF > /etc/yum.repos.d/gauge-stable.repo
[gauge-stable]
name=gauge-stable
baseurl=http://dl.bintray.com/gauge/gauge-rpm/gauge-stable
gpgcheck=0
enabled=1
EOF

  try yum install --assumeyes gauge
  try gauge --version
}

function install_jdks() {
  install_jdk11

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    install_jdk12
    install_jdk13
  fi
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

function install_sysvinit_tools() {
  try yum install --assumeyes sysvinit-tools
}

function install_native_build_packages() {
  try yum install --assumeyes \
      libxml2-devel libxslt-devel \
      zlib-devel bzip2-devel \
      glibc-devel autoconf bison flex kernel-devel libcurl-devel make cmake \
      openssl-devel libffi-devel libyaml-devel readline-devel libedit-devel bash \
      "devtoolset-${CENTOS_MAJOR_VERSION}-gcc-c++" "devtoolset-${CENTOS_MAJOR_VERSION}-gcc"

  # activate the newer gcc from SCL
  cat <<-EOF > /etc/profile.d/scl-gcc.sh
source /opt/rh/devtoolset-${CENTOS_MAJOR_VERSION}/enable
export PATH=\$PATH:/opt/rh/devtoolset-${CENTOS_MAJOR_VERSION}/root/usr/bin
export X_SCLS="\$(scl enable devtoolset-${CENTOS_MAJOR_VERSION} 'echo \$X_SCLS')"
EOF
}

function install_python() {
  try yum install --assumeyes python-devel python-pip python-virtualenv
  try python --version
}

function install_scm_tools() {
  install_git

  if [ "$CENTOS_MAJOR_VERSION" == "6" ]; then
    cat <<-EOF > /etc/yum.repos.d/rpmforge-extras.repo
[rpmforge-extras]
name=RHEL $releasever - RPMforge.net - extras
enabled=0
fastestmirror_enabled=0
gpgcheck=1
gpgkey=http://repository.it4i.cz/mirrors/repoforge/RPM-GPG-KEY.dag.txt
mirrorlist=http://mirrorlist.repoforge.org/el6/mirrors-rpmforge-extras
EOF
    try yum install --assumeyes mercurial --enablerepo=rpmforge-extras
else
    try yum install --assumeyes mercurial
  fi

  try yum install --assumeyes subversion

  try mkdir -p /usr/local/bin
  try curl --silent --fail --location https://s3.amazonaws.com/mirrors-archive/local/perforce/r${P4_VERSION}/bin.linux26x86_64/p4 --output /usr/local/bin/p4
  try curl --silent --fail --location https://s3.amazonaws.com/mirrors-archive/local/perforce/r${P4D_VERSION}/bin.linux26x86_64/p4d --output /usr/local/bin/p4d
  try chmod 755 /usr/local/bin/p4 /usr/local/bin/p4d

  try git --version
  try svn --version
  try hg --version
  try p4 -V
  try p4d -V
}

function install_git() {
  try yum -y install git224-core

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    setup_git_config
  fi
}

function install_installer_tools() {
  try yum install --assumeyes \
      dpkg-devel dpkg-dev \
      createrepo repoview yum-utils rpm-build fakeroot yum-utils \
      gnupg2 \
      http://gocd.github.io/nsis-rpm/rpms/mingw32-nsis-${NSIS_VERSION}.el6.x86_64.rpm

  try su - "$PRIMARY_USER" -c "gem install fpm --no-document"
}

function install_maven() {
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip --output /usr/local/src/apache-maven-${MAVEN_VERSION}-bin.zip
  try unzip -q /usr/local/src/apache-maven-${MAVEN_VERSION}-bin.zip -d /opt/local
  try ln -sf /opt/local/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn
}

function install_ant() {
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.zip --output /usr/local/src/apache-ant-${ANT_VERSION}-bin.zip
  try unzip -q /usr/local/src/apache-ant-${ANT_VERSION}-bin.zip -d /opt/local
  try ln -sf /opt/local/apache-ant-${ANT_VERSION}/bin/ant /usr/local/bin/ant
}

function install_awscli() {
  # `/etc/mime.types` is required by aws cli so it can generate appropriate `content-type` headers when uploading to s3. Without this file, all files in s3 will have content type `application/octet-stream`
  try yum install --assumeyes mailcap
  try pip install awscli
}

function setup_postgres_repo() {
  try yum install --assumeyes https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
}

function install_postgresql() {
  local pg_version="$1"
  package_suffix="$(echo ${pg_version} | sed -e 's/\.//g')"
  try yum install --assumeyes postgresql${package_suffix} postgresql${package_suffix}-devel postgresql${package_suffix}-server postgresql${package_suffix}-contrib
}

function install_xvfb() {
  try yum install --assumeyes xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-server-Xvfb mesa-libGL
}

function install_xss() {
  try yum install --assumeyes libXScrnSaver # Headless Chrome needs this for some reason
}

# for FF
function install_firefox_dependencies() {
  if [ "$CENTOS_MAJOR_VERSION" == "6" ]; then
    try yum install --assumeyes gnome-themes nspluginwrapper
  else
    try yum install --assumeyes gtk3
  fi

  try yum install --assumeyes libcroco
  try yum install --assumeyes \
      xdotool \
      hicolor-icon-theme \
      dbus dbus-x11 xauth liberation-sans-fonts liberation-serif-fonts liberation-mono-fonts mesa-dri-drivers \
      xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-fonts-cyrillic urw-fonts

  # install just the FF dependencies, without FF
  try yum install --assumeyes $(yum deplist firefox | awk '/provider:/ {print $2}' | sort -u)
}

function install_firefox_latest() {
  # latest versions of FF
  try mkdir -p /opt/local/firefox
  try mkdir -p /opt/local/firefox-latest
  try curl --silent --fail --location 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US' --output /usr/local/src/firefox-latest.tar.bz2
  try tar -jxf /usr/local/src/firefox-latest.tar.bz2 -C /opt/local/firefox-latest --strip-components=1
  if [ "$CENTOS_MAJOR_VERSION" == "7" ]; then
    try bash -c "dbus-uuidgen > /etc/machine-id"
  else
    try bash -c "dbus-uuidgen > /var/lib/dbus/machine-id"
  fi

  try ln -sf /opt/local/firefox-latest/firefox /usr/local/bin/firefox
  try /opt/local/firefox-latest/firefox -version
  try firefox -version
}

function install_tini() {
  local URL="$(curl --silent --fail --location https://github-api-proxy.gocd.org/repos/krallin/tini/releases/latest | jq -r '.assets[] | select(.name | match("-amd64.rpm$")) | .browser_download_url' | grep -v muslc)"
  yum install --assumeyes "${URL}"
  try tini --version
}

function install_geckodriver() {
  local URL="$(curl --silent --fail --location https://github-api-proxy.gocd.org/repos/mozilla/geckodriver/releases/latest | jq -r '.assets[] | select(.name | contains("linux64.tar.gz")) | .browser_download_url')"
  try curl --silent --fail --location "${URL}" --output /usr/local/src/geckodriver-latest.tar.gz
  try tar -zxf /usr/local/src/geckodriver-latest.tar.gz -C /usr/local/bin
}

function list_installed_packages() {
  try bash -c "rpm -qa | sort"
}

function clean() {
  try yum clean all
  try rm -rf /usr/local/src/*
}

function upgrade_os_packages() {
  try yum update --assumeyes --quiet
}

function add_gocd_user() {
  try useradd --home-dir /go --shell /bin/bash go
  try cp /usr/local/src/provision/gocd-sudoers /etc/sudoers.d/go
  try chmod 0440 /etc/sudoers.d/go
}

function setup_git_config() {
  try cp /usr/local/src/provision/gitconfig ~go/.gitconfig
  try chown go:go ~go/.gitconfig
}

function setup_nexus_configs() {
  setup_gradle_config
  setup_maven_config
  setup_rubygems_config
  setup_npm_config
}

function setup_gradle_config() {
  # internal nexus config
  try mkdir -p ~go/.gradle/
  try cp /usr/local/src/provision/init.gradle ~go/.gradle/init.gradle
  try chown go:go -R ~go/.gradle
}

function setup_maven_config() {
  # internal nexus config
  try mkdir -p ~go/.m2/
  try cp /usr/local/src/provision/settings.xml ~go/.m2/settings.xml
  try chown go:go -R ~go/.m2
}

function setup_rubygems_config() {
  # internal nexus config
  try mkdir -p ~go/.bundle/
  try cp /usr/local/src/provision/bundle-config ~go/.bundle/config
  try chown go:go -R ~go/.bundle
}

function setup_npm_config() {
  # internal nexus config
  try mkdir -p ~go/.bundle/
  try cp /usr/local/src/provision/npmrc ~go/.npmrc
  try chown go:go -R ~go/.npmrc
}

function add_golang_gocd_bootstrapper() {
  local URL="$(curl --silent --fail --location https://github-api-proxy.gocd.org/repos/ketan/gocd-golang-bootstrapper/releases/latest | jq -r '.assets[] | select(.name | contains("linux.amd64")) | .browser_download_url')"
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

function build_gocd() {
  try su - ${PRIMARY_USER} -c "git clone --depth 1 https://github.com/gocd/gocd /tmp/gocd && \
              cd /tmp/gocd && \
              jabba use openjdk@1.11 && ./gradlew --max-workers 4 compileAll yarnInstall --no-build-cache ${GRADLE_OPTIONS}"
  try rm -rf /tmp/gocd /${PRIMARY_USER}/.gradle/caches/build-cache-*
}

function install_docker() {
  try curl --silent --fail --location 'https://download.docker.com/linux/centos/docker-ce.repo' --output /etc/yum.repos.d/docker-ce.repo
  try yum install --assumeyes docker-ce
  try usermod -a -G docker ${PRIMARY_USER}
}

function yell() { echo "$0: $*" >&2; }
function die() { yell "$*"; exit 111; }
function try() { echo "\$ $@" 1>&2; "$@" || die "cannot $*"; }

provision
