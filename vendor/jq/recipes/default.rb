case node['platform_family']
when 'rhel', 'fedora'
  include_recipe 'yum-epel'
end

package 'jq'
