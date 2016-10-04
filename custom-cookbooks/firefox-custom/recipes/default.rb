# this package is here, just to pull down any FF dependencies
pkgs = ['firefox']

pkgs += %w(gnome-themes hicolor-icon-theme xdotool)

pkgs += %w(dbus dbus-x11 xauth liberation-sans-fonts liberation-serif-fonts liberation-mono-fonts mesa-dri-drivers)
# plugins
pkgs += %w(nspluginwrapper)
# x11 stuff
pkgs += %w(xorg-x11-fonts-100dpi xorg-x11-fonts-75dpi xorg-x11-fonts-Type1 xorg-x11-fonts-cyrillic urw-fonts)

package pkgs

zipfile                = ::File.join(Chef::Config[:file_cache_path], "firefox-#{node['firefox-custom']['version']}-bin.tar.bz2")
firefox_executable     = ::File.join(node['firefox-custom']['install_dir'], "firefox-#{node['firefox-custom']['version']}/firefox")
firefox_bin_executable = ::File.join(node['firefox-custom']['install_dir'], "firefox-#{node['firefox-custom']['version']}/firefox-bin")

remote_file zipfile do
  source   node['firefox-custom']['url']
  checksum node['firefox-custom']['checksum']
  not_if   { ::File.exist?(firefox_executable) }
end

directory ::File.join(node['firefox-custom']['install_dir'], "firefox-#{node['firefox-custom']['version']}") do
  mode      '0755'
  owner     'root'
  group     'root'
  recursive true
end

execute "install firefox v#{node['firefox-custom']['version']}" do
  creates firefox_executable
  command "tar -jxf #{zipfile} -C #{node['firefox-custom']['install_dir']}/firefox-#{node['firefox-custom']['version']} --strip-components=1"
end

link '/usr/local/bin/firefox' do
  to firefox_executable
end

link '/usr/local/bin/firefox-bin' do
  to firefox_bin_executable
end

file zipfile do
  action :delete
  backup false
end
