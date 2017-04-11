default['perforce']['version'] = '16.2'
# make sure it has a trailing slash on it
default['perforce']['base_url'] = 'http://ftp.perforce.com/perforce/'

case node[:os]
when "linux"
  default['perforce']['bin_dir']  = '/usr/local/bin'
when "windows"
  default['perforce']['bin_dir'] = 'C:\Program Files (x86)\Perforce'
end
