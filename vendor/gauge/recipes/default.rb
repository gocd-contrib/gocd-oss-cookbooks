if platform_family?('windows')
  include_recipe 'gauge::install_windows'
else
  include_recipe 'gauge::install_linux'
end
