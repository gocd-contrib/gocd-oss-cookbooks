yum_repository 'nsis' do
  description "NSIS RPM Repository"
  baseurl     "https://gocd.github.io/nsis-rpm/"
  gpgcheck    false
  action      :create
end

package 'mingw32-nsis' do
  if node['nsis']['version'] == 'latest'
    action :upgrade
  elsif node['nsis']['version']
    version node['nsis']['version']
  end
end
