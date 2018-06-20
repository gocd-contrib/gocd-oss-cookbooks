name             'gauge'
maintainer       'Ketan Padegaonkar'
maintainer_email 'ketanpadegaonkar@gmail.com'
license          'MIT'
source_url       'https://github.com/getgauge-contrib/gauge-cookbook'
issues_url       'https://github.com/getgauge-contrib/gauge-cookbook/issues'
chef_version     '>= 12.0.0'
description      'Installs/Configures gauge'
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '2.0.0'

%w(redhat centos scientific fedora amazon oracle debian ubuntu suse opensuse windows).each do |os|
  supports os
end

depends 'windows'
