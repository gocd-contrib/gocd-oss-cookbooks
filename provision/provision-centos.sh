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
MAVEN_VERSION=3.6.3
ANT_VERSION=1.10.8
P4_VERSION=15.1
P4D_VERSION=16.2

CENTOS_MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3 | cut -d"." -f1)
pkg="yum"

if command -v dnf &> /dev/null; then
  pkg="dnf"
fi

# import functions
source "$(dirname $0)/common.sh"

# Main entrypoint
function provision() {
  step setup_yum_external_repos

  # these are build prereqs for subsequent things; install
  # these early during provision
  step install_basic_utils
  step install_native_build_packages

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    # setup gocd user to use internal mirrors for builds
    step add_gocd_user
  fi

  # git, in particular, is used in subsequent provisioning
  # so do this before things like `rbenv` and `nodenv`
  step install_scm_tools

  step install_rbenv
  step install_global_ruby "2.7.1"

  step install_nodenv
  step install_global_node "14.5.0"
  step install_yarn

  step install_jabba
  step install_jdks "11" "12" "13" "14"
  step install_maven "$MAVEN_VERSION"
  step install_ant "$ANT_VERSION"

  step install_python

  step install_gauge "1.0.6"
  step install_installer_tools
  step install_awscli

  step setup_postgres_repo
  step install_postgresql "9.6"
  step install_postgresql "10"
  step install_postgresql "11"
  step install_postgresql "12"

  if [ "$CENTOS_MAJOR_VERSION" -eq 7 ]; then
    step install_sysvinit_tools
  fi

  if [ "$CENTOS_MAJOR_VERSION" -ge 7 ]; then
    step install_geckodriver
    step install_firefox_dependencies
    step install_firefox_latest
    step install_xvfb
    step install_xss
  fi

  # On Docker for Mac, make sure you allocate more than 2G of memory or
  # gradle might randomly fail; 6G should fairly reliable.
  step build_gocd

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    step install_docker
    step setup_nexus_configs
    step add_golang_gocd_bootstrapper
    step setup_entrypoint
  fi

  step install_tini

  step upgrade_os_packages
  step list_installed_packages
  step clean

  step print_versions_summary
}

function setup_epel() {
  try $pkg -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-${CENTOS_MAJOR_VERSION}.noarch.rpm
}

# Software Collections Library yum repo
# For recent-ish versions of `gcc` + friends
function setup_scl() {
  try $pkg -y install centos-release-scl
}

# https://ius.io/ - Inline with Upstream Stable yum repo
# For modern versions of `git`
function setup_ius() {
  try $pkg -y install "https://repo.ius.io/ius-release-el${CENTOS_MAJOR_VERSION}.rpm"
}

function setup_yum_external_repos() {
  setup_epel

  if [ "$CENTOS_MAJOR_VERSION" -ge 8 ]; then
    try $pkg -y install "${pkg}-command(config-manager)"
    try $pkg config-manager --set-enabled epel-testing
    try $pkg config-manager --set-enabled PowerTools
  else
    setup_ius
    setup_scl
  fi
}

function install_basic_utils() {
  # add some basic utils
  try $pkg -y install \
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

function install_sysvinit_tools() {
  try $pkg -y install sysvinit-tools
}

function install_native_build_packages() {
  try $pkg -y install \
      libxml2-devel libxslt-devel \
      zlib-devel bzip2-devel \
      glibc-devel autoconf bison flex kernel-devel libcurl-devel make cmake \
      openssl-devel libffi-devel libyaml-devel readline-devel libedit-devel bash

  if [ "$CENTOS_MAJOR_VERSION" -ge 8 ]; then
    try $pkg -y groupinstall "Development Tools"
  else
    try $pkg -y install \
      "devtoolset-${CENTOS_MAJOR_VERSION}-gcc-c++" \
      "devtoolset-${CENTOS_MAJOR_VERSION}-gcc"

    # activate the newer gcc from SCL
    cat <<-EOF > /etc/profile.d/scl-gcc.sh
source /opt/rh/devtoolset-${CENTOS_MAJOR_VERSION}/enable
export PATH=\$PATH:/opt/rh/devtoolset-${CENTOS_MAJOR_VERSION}/root/usr/bin
export X_SCLS="\$(scl enable devtoolset-${CENTOS_MAJOR_VERSION} 'echo \$X_SCLS')"
EOF
  fi
}

function install_python() {
  if [ "$CENTOS_MAJOR_VERSION" -ge 8 ]; then
    try $pkg -y install python3 python3-devel
    try alternatives --set python /usr/bin/python3
    try ln -s /usr/bin/pip3 /usr/bin/pip
  else
    try $pkg -y install python-devel python-pip python-virtualenv
  fi
  try python --version
}

function install_scm_tools() {
  install_git
  try $pkg -y install mercurial
  try $pkg -y install subversion

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
  local git_pkg="$([ "$CENTOS_MAJOR_VERSION" -ge 8 ] && printf git || printf git224-core)"
  try $pkg -y install $git_pkg

  if [ "${SKIP_INTERNAL_CONFIG}" != "yes" ]; then
    setup_git_config
  fi
}

function install_installer_tools() {
  if [ "$CENTOS_MAJOR_VERSION" -ge 8 ]; then
    try $pkg -y install python2 python2-devel \
      xz-lzma-compat # needed by dpkg-dev
    try pip2 install kid

    # python2-kid does not exist for CentOS 8; so broken dependencies using `dnf install`
    try rpm -Uvh --nodeps https://forensics.cert.org/centos/cert/8/x86_64/repoview-0.6.6-13.el8.noarch.rpm
  else
    try $pkg -y install repoview
  fi

  try $pkg -y install \
      dpkg-devel dpkg-dev \
      createrepo yum-utils rpm-build fakeroot \
      gnupg2 \
      http://gocd.github.io/nsis-rpm/rpms/mingw32-nsis-${NSIS_VERSION}.el6.x86_64.rpm

  try su - "$PRIMARY_USER" -c "gem install fpm --no-document"
}

function install_awscli() {
  # `/etc/mime.types` is required by aws cli so it can generate appropriate `content-type` headers when uploading to s3. Without this file, all files in s3 will have content type `application/octet-stream`
  try $pkg -y install mailcap
  try pip install awscli
}

function setup_postgres_repo() {
  try $pkg -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-$CENTOS_MAJOR_VERSION-x86_64/pgdg-redhat-repo-latest.noarch.rpm

  if [ "$CENTOS_MAJOR_VERSION" -ge 8 ]; then
    try $pkg -qy module disable postgresql
  fi
}

function install_postgresql() {
  local pg_version="$1"
  package_suffix="$(printf "${pg_version}" | sed -e 's/\.//g')"
  try $pkg -y install postgresql${package_suffix} postgresql${package_suffix}-devel postgresql${package_suffix}-server postgresql${package_suffix}-contrib
}

function install_xvfb() {
  try $pkg -y install xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-server-Xvfb mesa-libGL
}

function install_xss() {
  try $pkg -y install libXScrnSaver # Headless Chrome needs this for some reason
}

# for FF
function install_firefox_dependencies() {
  try $pkg -y install \
      gtk3 \
      libcroco \
      xdotool \
      hicolor-icon-theme \
      dbus dbus-x11 xauth liberation-sans-fonts liberation-serif-fonts liberation-mono-fonts mesa-dri-drivers \
      xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-fonts-cyrillic urw-fonts

  # install just the FF dependencies, without FF
  try $pkg -y install $($pkg deplist firefox | awk '/provider:/ {print $2}' | sort -u)
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

function list_installed_packages() {
  try bash -c "rpm -qa | sort"
}

function clean() {
  try $pkg clean all
  try rm -rf /usr/local/src/*
}

function upgrade_os_packages() {
  try $pkg -y update --quiet
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
              jabba use openjdk@1.11 && GRADLE_OPTS=-Dorg.gradle.daemon=false ./gradlew --max-workers 2 compileAll yarnInstall --no-build-cache ${GRADLE_OPTIONS}"
  try rm -rf /tmp/gocd /${PRIMARY_USER}/.gradle/caches/build-cache-*
}

function install_docker() {
  if [ "$CENTOS_MAJOR_VERSION" -ge 7 ]; then
    try systemctl disable firewalld # firewalld is probably not installed anyway, but it would need to be disabled to allow DNS in containers
    try $pkg -y install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
    try curl --silent --fail --location 'https://download.docker.com/linux/centos/docker-ce.repo' --output /etc/yum.repos.d/docker-ce.repo
    try $pkg -y install docker-ce
    try usermod -a -G docker ${PRIMARY_USER}
  else
    yell "Skipping docker install; need CentOS 7 or better."
  fi
}

provision
