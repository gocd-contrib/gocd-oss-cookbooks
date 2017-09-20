directory ::File.join(node['go-user']['home_dir'], '.m2') do
  unless node['platform_family'] == 'windows'
    owner 'go'
    group 'go'
    mode  '0755'
  end
end

cookbook_file ::File.join(node['go-user']['home_dir'], '.m2', 'settings.xml') do
  source 'settings.xml'
  unless node['platform_family'] == 'windows'
    owner 'go'
    group 'go'
    mode  '0600'
  end
end
