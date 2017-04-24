include_recipe 'postgresql::yum_pgdg_postgresql'

package %w(postgresql96 postgresql96-devel postgresql96-contrib postgresql96-server)

directory '/var/run/postgresql' do
  owner  'go'
  group  'go'
end

cookbook_file '/etc/profile.d/postgresql-custom.sh' do
  owner  'root'
  group  'root'
  mode   '0644'
end
