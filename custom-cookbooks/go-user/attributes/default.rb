if node['platform_family'] == 'windows'
  default['go-user']['home_dir'] = ::File.join(ENV['USERPROFILE'])
else
  default['go-user']['home_dir'] = '/go'
end
