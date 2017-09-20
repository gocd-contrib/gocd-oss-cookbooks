include_recipe "git"
include_recipe 'gocd-build-essentials::compression'
include_recipe 'gocd-build-essentials::dpkg'
include_recipe 'gocd-build-essentials::gpg'
include_recipe 'gocd-build-essentials::images'
include_recipe 'gocd-build-essentials::rpm'
include_recipe 'gocd-build-essentials::ssh'
include_recipe 'gocd-build-essentials::utils'
include_recipe 'gocd-build-essentials::xml'
include_recipe 'gocd-build-essentials::python'
include_recipe 'gcc-6'

package %w(glibc-devel autoconf bison flex gcc kernel-devel libcurl-devel make cmake openssl-devel libffi-devel libyaml-devel readline-devel libedit-devel bash)
