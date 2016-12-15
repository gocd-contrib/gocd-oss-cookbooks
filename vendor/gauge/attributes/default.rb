default['gauge']['version']  = "0.6.2"

if platform_family?('windows')
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86_64.exe"
    default['gauge']['checksum'] = '3e2bce4bdb520ea68299eede27f8575e84c465fca41cdf62badea4714277d9a4'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86.exe"
    default['gauge']['checksum'] = '29ed1ecf9c65b38df610a9fa83f6616d6a1116126b2f4e8dee39ff0c3f6550ea'
  end
else
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86_64.zip"
    default['gauge']['checksum'] = '081e06aaad450e5f421775dfba3de12bab80d1349eaf87de4b3027b7a30b688b'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86.zip"
    default['gauge']['checksum'] = '535a6ee331c3dfe283f8e202a2556aea4232a4c59537421c5a5b50b1cdc5bce8'
  end
end

default['gauge']['properties']['runner_connection_timeout'] = 60000
default['gauge']['properties']['plugin_connection_timeout'] = 10000
default['gauge']['properties']['plugin_kill_timeout']       = 4000
default['gauge']['properties']['runner_request_timeout']    = 60000
