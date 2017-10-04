include_recipe 'cloudcli::awscli'

cookbook_file "/etc/profile.d/awscli.sh" do
  owner 'root'
  group 'root'
  mode  '0644'
end
