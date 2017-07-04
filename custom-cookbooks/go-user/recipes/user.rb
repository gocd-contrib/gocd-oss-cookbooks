user 'go' do
  home node['go-user']['home_dir']
  shell '/bin/bash'
  manage_home true
  notifies :reload, 'ohai[reload_passwd]', :immediately
end

ohai 'reload_passwd' do
  action :nothing
  plugin 'etc'
end

package 'sudo'

file '/etc/sudoers.d/go' do
  owner 'root'
  group 'root'
  mode '0440'
  content "# This file is managed by chef, any changes will be lost\ngo ALL=(ALL) NOPASSWD:ALL\n"
end
