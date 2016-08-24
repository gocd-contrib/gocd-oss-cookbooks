user 'go' do
  home '/go'
  shell '/bin/bash'
  notifies :reload, 'ohai[reload_passwd]', :immediately
end

ohai 'reload_passwd' do
  action :nothing
  plugin 'etc'
end
