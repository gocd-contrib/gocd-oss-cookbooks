default['gauge']['version'] = '0.9.6'

if platform_family?('windows')
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86_64.exe"
    default['gauge']['checksum'] = '33161d71ca19540334e744d5ad570c97a3d6ad3e92a90458d3823ec3f88db3a4'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86.exe"
    default['gauge']['checksum'] = 'df94a8b64c95f53d991d3a45b3ff5699591a4522fa625cd87b24795e69170725'
  end
else
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86_64.zip"
    default['gauge']['checksum'] = '81315277152b6540967cacc17be599405df2bad46452f603a7b2c83e4b12a99e'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86.zip"
    default['gauge']['checksum'] = 'ecb49dcc7ee8b3b3eb150e5b1906e7e16675a1631bee240bc66036b1b5ca6271'
  end
end

default['gauge']['properties']['runner_connection_timeout'] = 60000
default['gauge']['properties']['plugin_connection_timeout'] = 10000
default['gauge']['properties']['plugin_kill_timeout']       = 4000
default['gauge']['properties']['runner_request_timeout']    = 60000
default['gauge']['properties']['check_updates']             = true
