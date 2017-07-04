default['go-user']['go-agent']['bootstrapper-version'] = '1.0'

if node['platform_family'] == 'windows'
  default['go-user']['go-agent']['bootstrapper_path'] = ::File.join(node['go-user']['home_dir'], 'go-agent.exe')
  default['go-user']['go-agent']['bootstrapper_url'] = "https://github.com/ketan/gocd-golang-bootstrapper/releases/download/#{node['go-user']['go-agent']['bootstrapper-version']}/go-bootstrapper-#{node['go-user']['go-agent']['bootstrapper-version']}.windows.amd64.exe"
  default['go-user']['go-agent']['bootstrapper_script'] = 'bootstrap.cmd'
else
  default['go-user']['go-agent']['bootstrapper_path'] = ::File.join(node['go-user']['home_dir'], 'go-agent')
  default['go-user']['go-agent']['bootstrapper_url'] = "https://github.com/ketan/gocd-golang-bootstrapper/releases/download/#{node['go-user']['go-agent']['bootstrapper-version']}/go-bootstrapper-#{node['go-user']['go-agent']['bootstrapper-version']}.linux.amd64"
  default['go-user']['go-agent']['bootstrapper_script'] = 'bootstrap.sh'
end
