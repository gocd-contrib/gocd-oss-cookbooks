remote_file '/go/go-agent' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'https://github.com/ketan/gocd-golang-bootstrapper/releases/download/0.5/go-bootstrapper-0.5.linux.amd64'
end
