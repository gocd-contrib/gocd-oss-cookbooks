include_recipe 'gauge'

node['gocd-gauge-wrapper']['plugins'].each do |plugin_name, plugin_version|
  gauge_plugin plugin_name do
    user    node['gocd-gauge-wrapper']['user']
    group   node['gocd-gauge-wrapper']['group']
    version plugin_version
    if platform_family?('windows')
      password node['gocd-gauge-wrapper']['password']
      domain   node['hostname']
    end
  end
end
