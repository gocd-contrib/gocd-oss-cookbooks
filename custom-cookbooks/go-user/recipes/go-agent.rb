remote_file node['go-user']['go-agent']['bootstrapper_path'] do
  unless node['platform_family'] == 'windows'
    owner 'root'
    group 'root'
    mode '0755'
  end
  source node['go-user']['go-agent']['bootstrapper_url']
end

cookbook_file node['go-user']['go-agent']['bootstrapper_script'] do
  unless node['platform_family'] == 'windows'
    owner 'root'
    group 'root'
    mode '0755'
  end
end
