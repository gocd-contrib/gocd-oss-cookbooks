default['yum']['rpmforge']['repositoryid'] = 'rpmforge'
default['yum']['rpmforge']['description'] = 'RHEL $releasever - RPMforge.net - dag'
default['yum']['rpmforge']['mirrorlist'] = (node['platform'] == 'amazon' ? 'http://mirrorlist.repoforge.org/el6/mirrors-rpmforge' : "http://mirrorlist.repoforge.org/el#{node['platform_version'].to_i}/mirrors-rpmforge")
default['yum']['rpmforge']['enabled'] = true
default['yum']['rpmforge']['managed'] = true
default['yum']['rpmforge']['gpgcheck'] = true
default['yum']['rpmforge']['gpgkey'] = 'http://apt.sw.be/RPM-GPG-KEY.dag.txt'
