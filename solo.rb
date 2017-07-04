chef_base_path = File.expand_path('../', __FILE__)

cookbook_path  [File.join(chef_base_path, 'custom-cookbooks'), File.join(chef_base_path, 'vendor')]
role_path      File.join(chef_base_path, 'roles')
data_bag_path File.join(chef_base_path, 'data_bags')

if ChefConfig.windows?
  json_attribs             File.join(chef_base_path, 'solo-windows.json')
else
  json_attribs             File.join(chef_base_path, 'solo-linux.json')
end

ssl_verify_mode   :verify_peer
log_level :info
verbose_logging    false

encrypted_data_bag_secret nil

if ChefConfig.windows?
  ohai.disabled_plugins += ['Packages']
end
