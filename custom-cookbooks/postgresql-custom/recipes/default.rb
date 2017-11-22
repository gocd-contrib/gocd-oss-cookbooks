include_recipe 'postgresql::yum_pgdg_postgresql'

case node['postgresql']['version']
when "9.2"
  package %w(postgresql92 postgresql92-devel postgresql92-server postgresql92-contrib)
when "9.3"
  package %w(postgresql93 postgresql93-devel postgresql93-server postgresql93-contrib)
when "9.4"
  package %w(postgresql94 postgresql94-devel postgresql94-server postgresql94-contrib)
when "9.5"
  package %w(postgresql95 postgresql95-devel postgresql95-server postgresql95-contrib)
when "9.6"
  package %w(postgresql96 postgresql96-devel postgresql96-server postgresql96-contrib)
end

directory '/var/run/postgresql' do
  owner  'go'
  group  'go'
end

file '/etc/profile.d/postgresql-custom.sh' do
  content "export PATH=$PATH:/usr/pgsql-#{node['postgresql']['version']}/bin"
  owner  'root'
  group  'root'
  mode   '0644'
end
