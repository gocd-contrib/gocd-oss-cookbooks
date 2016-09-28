remote_file '/bin/tini' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'https://github.com/krallin/tini/releases/download/v0.10.0/tini'
end
