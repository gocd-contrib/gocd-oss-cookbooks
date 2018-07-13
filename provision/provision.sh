#!/usr/bin/env bash

yell() { echo "$0: $*" >&2; }
die() { yell "$*"; exit 111; }
try() { echo "$ $@" 1>&2; "$@" || die "cannot $*"; }

NSIS_VERSION=2.51-15
MAVEN_VERSION=3.5.4
ANT_VERSION=1.10.4
P4_VERSION=15.1
P4D_VERSION=16.2
TINI_VERSION=0.18.0
FIREFOX_VERSION=24.5.0esr
POSTGRESQL_VERSION=9.6

CENTOS_MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)

function setup_repos() {
  try yum install --assumeyes --quiet \
      epel-release \
      centos-release-scl
}

function install_basic_utils() {
  # add some basic utils
  try yum install --assumeyes --quiet \
      ncurses \
      file \
      wget \
      curl \
      zip \
      unzip \
      tar \
      gzip \
      bzip2 \
      jq
}

function install_gocd_development_packages() {
  try yum install --assumeyes --quiet https://rpm.nodesource.com/pub_6.x/el/${CENTOS_MAJOR_VERSION}/x86_64/nodesource-release-el${CENTOS_MAJOR_VERSION}-1.noarch.rpm
  try yum install --assumeyes --quiet nodejs

  try curl --silent --fail --location https://dl.yarnpkg.com/rpm/yarn.repo --output /etc/yum.repos.d/yarn.repo
  try yum install --assumeyes --quiet yarn
  
  cat <<-EOF > /etc/yum.repos.d/gauge-stable.repo
[gauge-stable]
name=gauge-stable
baseurl=http://dl.bintray.com/gauge/gauge-rpm/gauge-stable
gpgcheck=0
enabled=1
EOF

  try yum install --assumeyes --quiet gauge

  try yum install --assumeyes --quiet java-1.8.0-openjdk java-1.8.0-openjdk-devel
}

function install_native_build_packages() {
  try yum install --assumeyes --quiet centos-release-scl # for gcc-6

  try yum install --assumeyes --quiet \
      libxml2-devel libxslt-devel \
      zlib-devel bzip2-devel \
      glibc-devel autoconf bison flex kernel-devel libcurl-devel make cmake \
      openssl-devel libffi-devel libyaml-devel readline-devel libedit-devel bash \
      devtoolset-6-gcc-c++ devtoolset-6-gcc

cat <<-EOF > /etc/profile.d/scl-gcc-6.sh
source /opt/rh/devtoolset-6/enable
export PATH=\$PATH:/opt/rh/devtoolset-6/root/usr/bin
export X_SCLS="\$(scl enable devtoolset-6 'echo \$X_SCLS')"
EOF

}

function install_ruby() {
  try yum install --assumeyes --quiet centos-release-scl # for ruby-2.3
  try yum install --assumeyes --quiet \
      rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygem-bundler rh-ruby23-ruby-irb rh-ruby23-rubygem-rake rh-ruby23-rubygem-psych libffi-devel

cat <<-EOF > /etc/profile.d/scl-rh-ruby23.sh
source /opt/rh/rh-ruby23/enable
export PATH=\$PATH:/opt/rh/rh-ruby23/root/usr/local/bin
export X_SCLS="\$(scl enable rh-ruby23 'echo \$X_SCLS')"
EOF
}

function install_python() {
  try yum install --assumeyes --quiet \
      python-devel \
      python-pip \
      python-virtualenv
}

function install_scm_tools() {
  try yum install --assumeyes --quiet \
      git \
      subversion \
      mercurial

  try mkdir -p /usr/local/bin 
  try curl --silent --fail --location https://s3.amazonaws.com/mirrors-archive/local/perforce/r${P4_VERSION}/bin.linux26x86_64/p4 --output /usr/local/bin/p4
  try curl --silent --fail --location https://s3.amazonaws.com/mirrors-archive/local/perforce/r${P4D_VERSION}/bin.linux26x86_64/p4d --output /usr/local/bin/p4d
  try chmod 755 /usr/local/bin/p4 /usr/local/bin/p4d
}

function install_installer_tools() {
  try yum install --assumeyes --quiet \
      dpkg-devel dpkg-dev \
      createrepo yum-utils rpm-build fakeroot yum-utils \
      gnupg2 \
      http://gocd.github.io/nsis-rpm/rpms/mingw32-nsis-${NSIS_VERSION}.el6.x86_64.rpm

  try bash -lc "gem install fpm --no-ri --no-rdoc"
}

function install_maven() {
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip --output /usr/local/src/apache-maven-${MAVEN_VERSION}-bin.zip
  try unzip -q /usr/local/src/apache-maven-${MAVEN_VERSION}-bin.zip
  try mv apache-maven-${MAVEN_VERSION} /opt/local/
  try ln -sf /opt/local/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn
}

function install_ant() {
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.zip --output /usr/local/src/apache-ant-${ANT_VERSION}-bin.zip
  try unzip -q /usr/local/src/apache-ant-${ANT_VERSION}-bin.zip
  try mv apache-ant-${ANT_VERSION} /opt/local/
  try ln -sf /opt/local/apache-ant-${ANT_VERSION}/bin/mvn /usr/local/bin/ant
}

function install_awscli() {
  try pip install awscli
}

function install_postgresql() {
  package_suffix="$(echo ${POSTGRESQL_VERSION} | sed -e 's/\.//g')"
  try yum install --assumeyes --quiet https://download.postgresql.org/pub/repos/yum/${POSTGRESQL_VERSION}/redhat/rhel-${CENTOS_MAJOR_VERSION}-x86_64/pgdg-centos96-${POSTGRESQL_VERSION}-3.noarch.rpm
  try yum install --assumeyes --quiet \
    postgresql${package_suffix} postgresql${package_suffix}-devel postgresql${package_suffix}-server postgresql${package_suffix}-contrib
}

function install_xvfb() {
  try yum install --assumeyes --quiet \
      xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-server-Xvfb mesa-libGL
}

# for FF
function install_firefox() {
  if [ "$CENTOS_MAJOR_VERSION" == "6" ]; then
    try yum install --assumeyes --quiet gnome-themes nspluginwrapper
  else
    try yum install --assumeyes --quiet gtk3
  fi

  try yum install --assumeyes --quiet \
      firefox \
      xdotool \
      hicolor-icon-theme \
      dbus dbus-x11 xauth liberation-sans-fonts liberation-serif-fonts liberation-mono-fonts mesa-dri-drivers \
      xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-fonts-cyrillic urw-fonts
}

function install_firefox() {
  try mkdir -p /opt/local/firefox
  try mkdir -p /opt/local/firefox-${FIREFOX_VERSION}
  try curl --silent --fail --location https://ftp.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2 --output /usr/local/src/firefox-${FIREFOX_VERSION}.tar.bz2
  try tar -jxf /usr/local/src/firefox-${FIREFOX_VERSION}.tar.bz2 -C /opt/local/firefox-${FIREFOX_VERSION} --strip-components=1
}

function install_firefox_latest() {
  # latest versions of FF
  try mkdir -p /opt/local/firefox
  try mkdir -p /opt/local/firefox-latest
  try curl --silent --fail --location 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US' --output /usr/local/src/firefox-latest.tar.bz2
  try tar -jxf /usr/local/src/firefox-latest.tar.bz2 -C /opt/local/firefox-latest --strip-components=1
  try ln -sf /opt/local/firefox-latest/firefox /usr/local/bin/firefox
}

function install_tini() {
  yum install --assumeyes --quiet https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}-amd64.rpm
}

function install_geckodriver() {
  URL="$(curl --silent --fail --location https://api.github.com/repos/mozilla/geckodriver/releases/latest | jq -r '.assets[] | select(.name | contains("linux64.tar.gz")) | .browser_download_url')"
  try curl --silent --fail --location "${URL}" --output /usr/local/src/geckodriver-latest.tar.gz
  try tar -zxf /usr/local/src/geckodriver-latest.tar.gz -C /usr/local/bin
}

function list_installed_packages() {
  try bash -c "rpm -qa | sort"
}

function clean() {
  try yum clean all
}

function upgrade_os_packages() {
  try yum update --assumeyes --quiet
}

function add_gocd_user() {
  try useradd --home-dir /go --shell /bin/bash go
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
  try cp /usr/local/src/provision/bootstrap.sh /bootstrap.sh
  try chmod 755 /bootstrap.sh
}

setup_repos

# install a bunch of stuff we need
install_basic_utils
install_gocd_development_packages
install_native_build_packages
install_ruby
install_python
install_scm_tools
install_installer_tools
install_maven
install_ant
install_awscli
install_xvfb
install_tini
install_geckodriver

# setup gocd user to use internal mirrors for builds
add_gocd_user
setup_git_config
setup_gradle_config
setup_maven_config
setup_rubygems_config
setup_npm_config
add_golang_gocd_bootstrapper
setup_entrypoint

upgrade_os_packages
list_installed_packages
clean
