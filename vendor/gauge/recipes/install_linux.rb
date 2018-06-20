case node['platform_family']
when 'rhel', 'fedora', 'suse', 'amazon'
  yum_repository 'gauge-stable' do
    description 'Gauge stable repository'
    baseurl     "http://dl.bintray.com/gauge/gauge-rpm/gauge-stable"
    gpgcheck    false
    action      :create
  end

when 'debian'

  apt_repository 'gauge' do
    uri          'https://dl.bintray.com/gauge/gauge-deb'
    components   ['main']
    keyserver    'hkp://pool.sks-keyservers.net'
    key          '023EDB0B'
    distribution 'stable'
    action       :add
  end

end

package 'gauge' do
  if node['gauge']['version'] == 'latest'
    action :upgrade
  elsif node['gauge']['version']
    version node['gauge']['version']
  end
end