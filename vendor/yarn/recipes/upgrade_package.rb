#
# Cookbook Name:: yarn
# Recipe:: upgrade_package
#
# Author: Alexander Pyatkin <aspyatkin@gmail.com>
# Author: Dieter Blomme <dieterblomme@gmail.com>
#
# Copyright 2017
#

include_recipe 'yarn::repository'

package 'yarn' do
  version node['yarn']['package']['version']
  action :upgrade
end
