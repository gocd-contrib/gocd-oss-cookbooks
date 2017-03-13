remote_file '/go/go-agent' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'https://github.com/ketan/gocd-golang-bootstrapper/releases/download/0.8/go-bootstrapper-0.8.linux.amd64'
end

cookbook_file '/bootstrap.sh' do
  owner 'root'
  group 'root'
  mode '0755'
end
