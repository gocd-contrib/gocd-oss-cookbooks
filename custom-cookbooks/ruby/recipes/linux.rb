include_recipe "software-collections"
include_recipe "gcc-6"

package %w(rh-ruby23 rh-ruby23-ruby-devel rh-ruby23-rubygem-bundler rh-ruby23-ruby-irb rh-ruby23-rubygem-rake rh-ruby23-rubygem-psych libffi-devel)

cookbook_file "/etc/profile.d/scl-rh-ruby23.sh" do
  owner 'root'
  group 'root'
  mode  '0644'
end
