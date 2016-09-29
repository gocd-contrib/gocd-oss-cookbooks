default['firefox-custom']['version']     = '24.5.0esr'
default['firefox-custom']['install_dir'] = '/opt/local/firefox'
default['firefox-custom']['url']         = "https://ftp.mozilla.org/pub/firefox/releases/#{node['firefox-custom']['version']}/linux-x86_64/en-US/firefox-#{node['firefox-custom']['version']}.tar.bz2"
default['firefox-custom']['checksum']    = "e7ed32539526c843fc5d4e0cd3c7a1a370ecb797e0edf3d3d1d5eb9ff79c41e7"
