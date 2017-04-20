directory '/go/.bundle' do
  owner 'go'
  group 'go'
  mode  '0755'
end

cookbook_file '/go/.bundle/config' do
  source 'bundle-config'
  owner 'go'
  group 'go'
  mode  '0600'
end
