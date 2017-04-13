include_recipe 'postgresql::yum_pgdg_postgresql'

package %w(postgresql95 postgresql95-devel postgresql95-contrib postgresql95-server)

directory '/var/run/postgresql' do
  owner  'go'
  group  'go'
end

cookbook_file '/etc/profile.d/postgresql-custom.sh' do
  owner  'root'
  group  'root'
  mode   '0644'
end
