p4_exe = node[:os] == 'windows' ? 'p4.exe' : 'p4'
p4d_exe = node[:os] == 'windows' ? 'p4d.exe' : 'p4d'

directory node['perforce']['bin_dir'] do
  recursive true
end


p4_exe_url = get_ftp_path(node['perforce']['version'], p4_exe)
remote_file ::File.join(node['perforce']['bin_dir'], p4_exe) do
  source p4_exe_url

  if node[:os] == 'windows'
    rights :read_execute, 'Everyone'
    rights :full_control, 'Administrators'
  else
    owner 'root'
    group 'root'
    mode 00755
  end

end

p4d_exe_url = get_ftp_path(node['perforce']['version'], p4d_exe)
remote_file ::File.join(node['perforce']['bin_dir'], p4d_exe) do
  source p4d_exe_url

  if node[:os] == 'windows'
    rights :read_execute, 'Everyone'
    rights :full_control, 'Administrators'
  else
    owner 'root'
    group 'root'
    mode 00755
  end
end

if node[:os] == 'windows'
  windows_path node['perforce']['bin_dir'] do
    action :add
  end
end
