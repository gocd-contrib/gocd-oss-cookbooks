default['yum']['rpmforge-extras']['repositoryid'] = 'rpmforge-extras'
default['yum']['rpmforge-extras']['description'] = 'RHEL $releasever - RPMforge.net - extras'
default['yum']['rpmforge-extras']['mirrorlist'] = (node['platform'] == 'amazon' ? 'http://mirrorlist.repoforge.org/el6/mirrors-rpmforge-extras' : "http://mirrorlist.repoforge.org/el#{node['platform_version'].to_i}/mirrors-rpmforge-extras")
default['yum']['rpmforge-extras']['enabled'] = true
default['yum']['rpmforge-extras']['managed'] = true
default['yum']['rpmforge-extras']['gpgcheck'] = true
default['yum']['rpmforge-extras']['gpgkey'] = 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
