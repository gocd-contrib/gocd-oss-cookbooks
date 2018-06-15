default['gauge']['version'] = '0.9.9'

if platform_family?('windows')
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86_64.exe"
    default['gauge']['checksum'] = '0ca9c62a2ee66a5a9f7c316b228d7e8370521590335a3c9085e8a371e77f111e'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-windows.x86.exe"
    default['gauge']['checksum'] = '236444c3627fe03a4b18cea6cef463a004ad0262d217e9ac73a710fda810d4ec'
  end
else
  if node['kernel']['machine'] =~ /x86_64/
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86_64.zip"
    default['gauge']['checksum'] = '1270414eec5c0f2598c13670fd3fcf054fa74d5605695648403adcaf7e101170'
  else
    default['gauge']['url']      = "https://github.com/getgauge/gauge/releases/download/v#{node['gauge']['version']}/gauge-#{node['gauge']['version']}-linux.x86.zip"
    default['gauge']['checksum'] = 'a3e9cf15160482506b5033d300c6abc8c636c4b151f8c1693e2b6e408963daab'
  end
end

default['gauge']['properties']['runner_connection_timeout'] = 60000
default['gauge']['properties']['plugin_connection_timeout'] = 10000
default['gauge']['properties']['plugin_kill_timeout']       = 4000
default['gauge']['properties']['runner_request_timeout']    = 60000
default['gauge']['properties']['check_updates']             = true
