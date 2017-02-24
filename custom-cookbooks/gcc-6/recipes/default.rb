include_recipe 'software-collections::default'

package %w(devtoolset-6-gcc-c++ devtoolset-6-gcc)

cookbook_file "/etc/profile.d/scl-gcc-6.sh" do
  owner 'root'
  group 'root'
  mode  '0644'
end
