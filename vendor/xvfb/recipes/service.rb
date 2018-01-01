family = platform_family?('debian') ? 'debian' : 'rhel'

template '/etc/init.d/xvfb' do
  source "#{family}.erb"
  mode '0755'
  variables(
    display: node['xvfb']['display'],
    screen_number: node['xvfb']['screen']['number'],
    screen_resolution: node['xvfb']['screen']['resolution'],
    args: node['xvfb']['option']
  )
  notifies(:restart, 'service[xvfb]')
end

service 'xvfb' do
  action [:enable, :start]
end
