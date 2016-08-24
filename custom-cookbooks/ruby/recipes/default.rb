if node['platform_family'] === 'windows'
  include_recipe 'ruby::windows'
else
  include_recipe 'ruby::linux'
end
