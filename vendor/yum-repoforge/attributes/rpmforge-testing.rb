default['yum']['rpmforge-testing']['repositoryid'] = 'rpmforge-testing'
default['yum']['rpmforge-testing']['description'] = 'RHEL $releasever - RPMforge.net - testing'
default['yum']['rpmforge-testing']['mirrorlist'] = (node['platform'] == 'amazon' ? 'http://mirrorlist.repoforge.org/el6/mirrors-rpmforge-testing' : "http://mirrorlist.repoforge.org/el#{node['platform_version'].to_i}/mirrors-rpmforge-testing")
default['yum']['rpmforge-testing']['enabled'] = true
default['yum']['rpmforge-testing']['managed'] = false
default['yum']['rpmforge-testing']['gpgcheck'] = true
default['yum']['rpmforge-testing']['gpgkey'] = 'https://repository.it4i.cz/mirrors/repoforge/RPM-GPG-KEY.dag.txt'
