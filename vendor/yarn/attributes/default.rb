#
# Cookbook Name:: yarn
# Attributes:: default
#
# Author: Alexander Pyatkin <aspyatkin@gmail.com>
# Author: Dieter Blomme <dieterblomme@gmail.com>
#
# Copyright 2017
#

default['yarn']['package'].tap do |package|
  package['upgrade'] = true
  package['version'] = nil

  package['repository']['uri'] = case node['platform_family']
                         when 'debian' then 'https://dl.yarnpkg.com/debian/'
                         when 'rhel' then 'https://dl.yarnpkg.com/rpm/'
                         end
  package['repository']['key'] = case node['platform_family']
                         when 'debian' then 'https://dl.yarnpkg.com/debian/pubkey.gpg'
                         when 'rhel' then 'https://dl.yarnpkg.com/rpm/pubkey.gpg'
                         end
  package['repository']['distribution'] = 'stable'
  package['repository']['components'] = %w(
    main
  )
end
