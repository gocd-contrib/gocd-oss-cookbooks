default['perforce']['version'] = '09.2'

case node[:os]
when "linux"
  default['perforce']['bin_dir']  = '/usr/local/bin'
when "windows"
  default['perforce']['bin_dir'] = 'C:\Program Files (x86)\Perforce'
end
