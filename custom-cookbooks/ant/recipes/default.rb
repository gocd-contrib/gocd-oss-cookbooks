zipfile = "#{Chef::Config[:file_cache_path]}/apache-ant-#{node['ant']['version']}-bin.tar.gz"

remote_file zipfile do
  source node['ant']['url']
  checksum node['ant']['checksum']
  not_if {::File.exist?(::File.join(node['ant']['install_dir'], "apache-ant-#{node['ant']['version']}")) }
end

directory node['ant']['install_dir'] do
  if node['platform_family'] != 'windows'
    mode  '0755'
    owner 'root'
    group 'root'
  end
  recursive true
end

execute "install ant v#{node['ant']['version']}" do
  creates ::File.join(node['ant']['install_dir'], "apache-ant-#{node['ant']['version']}")
  command "tar -zxf #{zipfile} -C #{node['ant']['install_dir']}"
end

if node['platform_family'] === 'windows'
  windows_path "#{node['ant']['install_dir']}\\apache-ant-#{node['ant']['version']}\\bin" do
    action :add
  end
else
  link "/usr/local/bin/ant" do
    to ::File.join(node['ant']['install_dir'], "apache-ant-#{node['ant']['version']}/bin/ant")
  end
end

file zipfile do
  action :delete
  backup false
end
