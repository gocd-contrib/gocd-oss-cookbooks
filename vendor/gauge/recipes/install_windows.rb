windows_package "Gauge #{node['gauge']['version']}" do
  version   node['gauge']['version']
  source    node['gauge']['url']
  checksum  node['gauge']['checksum']
end

template "#{ENV['APPDATA']}\\Gauge\\config\\gauge.properties"
