#
# Cookbook Name:: zip
# Recipe:: default
#
# Copyright 2011-2012, Phil Cohen
#

# apt-get
package "zip"
if platform_family?("rhel", "centos")
  package "unzip"
end
