directory ::File.join(node['go-user']['home_dir']) do
  unless node['platform_family'] == 'windows'
    owner 'go'
    group 'go'
    mode  '0755'
  end
end

cookbook_file ::File.join(node['go-user']['home_dir'], '.gitconfig') do
  source 'gitconfig'
  unless node['platform_family'] == 'windows'
    owner 'go'
    group 'go'
    mode  '0600'
  end
end
