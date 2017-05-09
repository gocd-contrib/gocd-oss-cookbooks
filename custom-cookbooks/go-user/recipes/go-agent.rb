remote_file '/go/go-agent' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'https://github.com/ketan/gocd-golang-bootstrapper/releases/download/1.0/go-bootstrapper-1.0.linux.amd64'
end

cookbook_file '/bootstrap.sh' do
  owner 'root'
  group 'root'
  mode '0755'
end
