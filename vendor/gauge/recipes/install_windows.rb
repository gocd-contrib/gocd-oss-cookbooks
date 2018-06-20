chocolatey_package 'package_name' do
  if node['gauge']['version'] == 'latest'
    action :upgrade
  elsif node['gauge']['version']
    version node['gauge']['version']
  end
end
