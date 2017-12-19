include_recipe 'postgresql::yum_pgdg_postgresql'

pg_version = node['postgresql']['pg_version']

# Convert 9.6 to 96 to install the right packages
pg_package_version = pg_version.gsub(/\./, '')

package %W{ postgresql#{pg_package_version} postgresql#{pg_package_version}-devel postgresql#{pg_package_version}-server postgresql#{pg_package_version}-contrib }

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
