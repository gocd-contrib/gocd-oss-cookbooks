default['gauge']['version']  = "0.6.1"

if platform_family?('windows')
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86_64.exe"
    default['gauge']['checksum'] = 'a80d25cf0b77000a883ee4e62cc6c27faea407930766f65f1437cf04671b970f'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86.exe"
    default['gauge']['checksum'] = '8a422cff743ef4c55e6aa74f18fa3c897a55871446a7cdf6cd7fbfda554f1135'
  end
else
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86_64.zip"
    default['gauge']['checksum'] = '727e75d5b09dbd79a82e9ec3cbff1b81983d0b5940fc8017a0e664c402ac38ac'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86.zip"
    default['gauge']['checksum'] = 'e0b041f0c9e0bff08b147107e4f2229ead2aeda1908008ac5a1268895b04a0ac'
  end
end

default['gauge']['properties']['runner_connection_timeout'] = 60000
default['gauge']['properties']['plugin_connection_timeout'] = 10000
default['gauge']['properties']['plugin_kill_timeout']       = 4000
default['gauge']['properties']['runner_request_timeout']    = 60000
