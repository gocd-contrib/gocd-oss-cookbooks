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
POSTGRESQL_VERSION=9.6

CENTOS_MAJOR_VERSION=$(rpm -qa \*-release | grep -Ei "oracle|redhat|centos" | cut -d"-" -f3)

function setup_epel() {
  try yum install --assumeyes epel-release
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

function install_node() {
  try yum install --assumeyes https://rpm.nodesource.com/pub_6.x/el/${CENTOS_MAJOR_VERSION}/x86_64/nodesource-release-el${CENTOS_MAJOR_VERSION}-1.noarch.rpm
  try yum install --assumeyes nodejs
  try node --version
}

function install_yarn() {
  try curl --silent --fail --location https://dl.yarnpkg.com/rpm/yarn.repo --output /etc/yum.repos.d/yarn.repo
  try yum install --assumeyes yarn
  try yarn --version
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

function install_openjdk() {
  try yum install --assumeyes java-1.8.0-openjdk java-1.8.0-openjdk-devel
  try java -version
}

function install_native_build_packages() {
  try yum install --assumeyes centos-release-scl # for gcc-6

  try yum install --assumeyes \
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
  try yum install --assumeyes centos-release-scl # for ruby-2.3
  try yum install --assumeyes \
      rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygem-bundler rh-ruby23-ruby-irb rh-ruby23-rubygem-rake rh-ruby23-rubygem-psych libffi-devel

cat <<-EOF > /etc/profile.d/scl-rh-ruby23.sh
source /opt/rh/rh-ruby23/enable
export PATH=\$PATH:/opt/rh/rh-ruby23/root/usr/local/bin
export X_SCLS="\$(scl enable rh-ruby23 'echo \$X_SCLS')"
EOF
  try bash -lc "ruby --version"
}

function install_python() {
  try yum install --assumeyes python-devel python-pip python-virtualenv
  try python --version
}

function install_scm_tools() {
  try yum install --assumeyes git subversion mercurial

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

function install_installer_tools() {
  try yum install --assumeyes \
      dpkg-devel dpkg-dev \
      createrepo yum-utils rpm-build fakeroot yum-utils \
      gnupg2 \
      http://gocd.github.io/nsis-rpm/rpms/mingw32-nsis-${NSIS_VERSION}.el6.x86_64.rpm

  try bash -lc "gem install fpm --no-ri --no-rdoc"
}

function install_maven() {
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.zip --output /usr/local/src/apache-maven-${MAVEN_VERSION}-bin.zip
  try unzip -q /usr/local/src/apache-maven-${MAVEN_VERSION}-bin.zip -d /opt/local
  try ln -sf /opt/local/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn
  try mvn -version
}

function install_ant() {
  try mkdir -p /opt/local/
  try curl --silent --fail --location http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.zip --output /usr/local/src/apache-ant-${ANT_VERSION}-bin.zip
  try unzip -q /usr/local/src/apache-ant-${ANT_VERSION}-bin.zip -d /opt/local
  try ln -sf /opt/local/apache-ant-${ANT_VERSION}/bin/ant /usr/local/bin/ant
  try ant -version
}

function install_awscli() {
  try pip install awscli
}

function install_postgresql() {
  package_suffix="$(echo ${POSTGRESQL_VERSION} | sed -e 's/\.//g')"
  try yum install --assumeyes https://download.postgresql.org/pub/repos/yum/${POSTGRESQL_VERSION}/redhat/rhel-${CENTOS_MAJOR_VERSION}-x86_64/pgdg-centos96-${POSTGRESQL_VERSION}-3.noarch.rpm
  try yum install --assumeyes \
    postgresql${package_suffix} postgresql${package_suffix}-devel postgresql${package_suffix}-server postgresql${package_suffix}-contrib
}

function install_xvfb() {
  try yum install --assumeyes xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-server-Xvfb mesa-libGL
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
  URL="$(curl --silent --fail --location https://api.github.com/repos/krallin/tini/releases/latest | jq -r '.assets[] | select(.name | match("-amd64.rpm$")) | .browser_download_url' | grep -v muslc)"
  yum install --assumeyes "${URL}"
  try tini --version
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

function build_gocd() {
  try su - go -c "git clone --depth 1 https://github.com/gocd/gocd /tmp/gocd && \
              cd /tmp/gocd && \
              ./gradlew compileAll yarnInstall --no-build-cache"
  try rm -rf /tmp/gocd /home/go/.gradle/caches/build-cache-*
}

setup_epel

install_basic_utils
install_node
install_yarn
install_gauge
install_openjdk
install_native_build_packages
install_ruby
install_python
install_scm_tools
install_installer_tools
install_maven
install_ant
install_awscli
install_postgresql

if [ "$CENTOS_MAJOR_VERSION" == "7" ]; then
  install_geckodriver
  install_firefox_dependencies
  install_firefox_latest
  install_xvfb
fi

# setup gocd user to use internal mirrors for builds
add_gocd_user
setup_git_config
build_gocd

setup_gradle_config
setup_maven_config
setup_rubygems_config
setup_npm_config

add_golang_gocd_bootstrapper
setup_entrypoint
install_tini

upgrade_os_packages
list_installed_packages
clean
