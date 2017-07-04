cookbook_file ::File.join(node['go-user']['home_dir'], '.npmrc') do
  source 'npmrc'
  unless node['platform_family'] == 'windows'
    owner 'go'
    group 'go'
    mode  '0600'
  end
end
