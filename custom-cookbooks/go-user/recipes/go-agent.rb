remote_file '/go/go-agent' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'https://github.com/ketan/gocd-golang-bootstrapper/releases/download/0.7/go-bootstrapper-0.7.linux.amd64'
end
