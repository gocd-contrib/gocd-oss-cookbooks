zipfile = "#{Chef::Config[:file_cache_path]}/phantomjs-#{node['phantomjs']['version']}-linux-x86_64.tar.bz2"

remote_file zipfile do
  source    node['phantomjs']['url']
  checksum  node['phantomjs']['checksum']
  not_if    {::File.exist?("/opt/local/phantomjs/phantomjs-#{node['phantomjs']['version']}-linux-x86_64") }
end

directory "/opt/local/phantomjs" do
  owner     'root'
  group     'root'
  mode      '0755'
  recursive true
end

execute "install phantomjs v#{node['phantomjs']['version']}" do
  creates "/opt/local/phantomjs/phantomjs-#{node['phantomjs']['version']}-linux-x86_64/"
  command "tar -jxf #{zipfile} -C /opt/local/phantomjs"
end

link "/usr/local/bin/phantomjs" do
  to "/opt/local/phantomjs/phantomjs-#{node['phantomjs']['version']}-linux-x86_64/bin/phantomjs"
end

file zipfile do
  action :delete
  backup false
end
