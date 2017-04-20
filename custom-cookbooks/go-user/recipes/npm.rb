cookbook_file '/go/.npmrc' do
  source 'npmrc'
  owner 'go'
  group 'go'
  mode  '0600'
end
