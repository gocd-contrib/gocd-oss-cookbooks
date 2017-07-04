ips = node[:hosts_file][:custom_entries].keys.sort - ['127.0.0.1']

ips.each_with_index do |ip, index|
  hosts = node[:hosts_file][:custom_entries][ip] - [node['fqdn']]
  host_ar = Array(hosts)
  next if host_ar.empty?
  hn = host_ar.first
  als = host_ar[1, host_ar.size]
  hostsfile_entry ip do
    unique true
    hostname hn
    aliases als unless als.empty?
    action [:create, :update]
  end
end
