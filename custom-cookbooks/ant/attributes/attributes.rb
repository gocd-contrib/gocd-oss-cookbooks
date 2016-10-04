default['ant']['version']  = "1.9.7"
default['ant']['url']      = "http://archive.apache.org/dist/ant/binaries/apache-ant-#{node['ant']['version']}-bin.tar.gz"
default['ant']['checksum'] = '1d0b808fe82cce9bcc167f8dbb7c7e89c1d7f7534c0d9c64bf615ec7c3e6bfe5'

if node['platform_family'] === 'windows'
  default['ant']['install_dir'] = 'C:\ant'
else
  default['ant']['install_dir'] = '/opt/local/ant'
end
