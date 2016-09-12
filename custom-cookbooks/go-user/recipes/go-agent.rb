remote_file '/go/go-agent' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'https://github.com/ketan/gocd-golang-bootstrapper/releases/download/0.3/go-bootstrapper-0.3.linux.amd64'
end
