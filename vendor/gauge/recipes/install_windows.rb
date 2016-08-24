windows_package "Gauge #{node['gauge']['version']}" do
  version   node['gauge']['version']
  source    node['gauge']['url']
  checksum  node['gauge']['checksum']
end

template 'C:\Program Files\Gauge\share\gauge\gauge.properties'
