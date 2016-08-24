include_recipe 'vnc'
include_recipe 'icewm'

bash "set vnc password for go user" do
  code %Q{
    echo '123456' > #{Chef::Config[:file_cache_path]}/vncpasswd-go
    echo '123456' >> #{Chef::Config[:file_cache_path]}/vncpasswd-go
    su -l go -c "vncpasswd < #{Chef::Config[:file_cache_path]}/vncpasswd-go > /dev/null 2>&1"
    rm #{Chef::Config[:file_cache_path]}/vncpasswd-go
  }
end

directory "/go/.vnc" do
  mode  "0755"
  owner "go"
  group "go"
end

cookbook_file "/go/.vnc/xstartup" do
  mode  "0755"
  owner "go"
  group "go"
end

directory "/go/.icewm" do
  mode  "0755"
  owner "go"
  group "go"
end

# set the icewm theme
file '/go/.icewm/theme' do
  content 'Theme="clearlooks-2px/default.theme"'
  mode  "0644"
  owner "go"
  group "go"
end
