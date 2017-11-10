bit = node['kernel']['machine'] == 'x86_64' ? '64' : '32'
ext = 'tar.gz'

case node['platform']
when 'windows'
  os = 'win'
  ext = 'zip'
when 'mac_os_x'
  os = 'macos'
  bit = ''
else
  os = 'linux'
end

version = node['geckodriver']['version']
name = "geckodriver-#{version}-#{os}#{bit}"
home = node['geckodriver']['home']

directory home do
  action :create
end

driver_path = "#{home}/#{name}"

directory driver_path do
  recursive true
  action :create
end

cache_path = "#{Chef::Config[:file_cache_path]}/#{name}.#{ext}"

if platform?('windows') # ~FC023
  powershell_script "unzip #{cache_path}" do
    code "Add-Type -A 'System.IO.Compression.FileSystem';" \
        " [IO.Compression.ZipFile]::ExtractToDirectory('#{cache_path}', '#{driver_path}');"
    action :nothing
  end
else
  execute "untar #{cache_path}" do
    command "tar -xvzf #{cache_path} -C #{driver_path} && chmod -R 0755 #{driver_path}"
    action :nothing
  end
end

src = "#{node['geckodriver']['url']}/#{version}/#{name}.#{ext}"

remote_file "download #{src}" do
  path cache_path
  source src
  notifies :run, "powershell_script[unzip #{cache_path}]", :immediately if platform?('windows')
  notifies :run, "execute[untar #{cache_path}]", :immediately unless platform?('windows')
end

case node['platform_family']
when 'windows'
  link "#{home}/geckodriver.exe" do
    to "#{driver_path}/geckodriver.exe"
  end

  env 'geckodriver path' do
    key_name 'PATH'
    action :modify
    delim ::File::PATH_SEPARATOR
    value home
  end
when 'mac_os_x'
  link '/usr/local/bin/geckodriver' do
    to "#{driver_path}/geckodriver"
  end
else # unix
  link '/usr/bin/geckodriver' do
    to "#{driver_path}/geckodriver"
  end
end
