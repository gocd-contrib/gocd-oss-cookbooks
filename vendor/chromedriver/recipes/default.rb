require 'net/http'

bit = '32'
case node['platform']
when 'windows'
  os = 'win'
when 'mac_os_x'
  os = 'mac'
else
  os = 'linux'
  bit = '64' if node['kernel']['machine'] == 'x86_64'
end

version = node['chromedriver']['version']
version = Chef::HTTP.new(node['chromedriver']['url']).get('/LATEST_RELEASE').strip if version == 'LATEST_RELEASE'

name = "chromedriver_#{os}#{bit}-#{version}"
home = platform?('windows') ? node['chromedriver']['windows']['home'] : node['chromedriver']['unix']['home']

directory home do
  action :create
end

driver_path = "#{home}/#{name}"

directory driver_path do
  action :create
end

cache_path = "#{Chef::Config[:file_cache_path]}/#{name}.zip"

if platform?('windows') # ~FC023
  powershell_script "unzip #{cache_path}" do
    code "Add-Type -A 'System.IO.Compression.FileSystem';" \
        " [IO.Compression.ZipFile]::ExtractToDirectory('#{cache_path}', '#{driver_path}');"
    action :nothing
  end
else
  package 'unzip' unless platform?('mac_os_x')

  execute "unzip #{cache_path}" do
    command "unzip -o #{cache_path} -d #{driver_path} && chmod -R 0755 #{driver_path}"
    action :nothing
  end
end

remote_file "download #{cache_path}" do
  path cache_path
  source "#{node['chromedriver']['url']}/#{version}/chromedriver_#{os}#{bit}.zip"
  use_etag true
  use_conditional_get true
  notifies :run, "powershell_script[unzip #{cache_path}]", :immediately if platform?('windows')
  notifies :run, "execute[unzip #{cache_path}]", :immediately unless platform?('windows')
end

case node['platform_family']
when 'windows'
  link "#{home}/chromedriver.exe" do
    to "#{driver_path}/chromedriver.exe"
  end

  env 'chromedriver path' do
    key_name 'PATH'
    action :modify
    delim ::File::PATH_SEPARATOR
    value home
  end
else # linux
  link '/usr/bin/chromedriver' do
    to "#{driver_path}/chromedriver"
  end
end
