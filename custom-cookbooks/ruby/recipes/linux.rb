include_recipe "software-collections"
include_recipe "gcc-6"

package %w(rh-ruby22 rh-ruby22-ruby-devel rh-ruby22-rubygem-bundler rh-ruby22-ruby-irb rh-ruby22-rubygem-rake rh-ruby22-rubygem-psych libffi-devel)

cookbook_file "/etc/profile.d/scl-rh-ruby22.sh" do
  owner 'root'
  group 'root'
  mode  '0644'
end
