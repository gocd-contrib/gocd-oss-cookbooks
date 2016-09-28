directory '/go/.m2' do
  owner 'go'
  group 'go'
  mode  '0755'
end

cookbook_file '/go/.m2/settings.xml' do
  owner 'go'
  group 'go'
  mode  '0600'
end
