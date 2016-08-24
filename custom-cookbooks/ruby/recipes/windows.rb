include_recipe '7-zip'

zipfile = "#{Chef::Config[:file_cache_path]}/ruby-1.9.3-p551-i386-mingw32.7z"

remote_file zipfile do
  source    'http://dl.bintray.com/oneclick/rubyinstaller/ruby-1.9.3-p551-i386-mingw32.7z'
  checksum  '207fdb5b2f9436ad1ac27bf51918b913c14c443d1b83cd910cf5a59acaeab756'
  not_if    {::File.exist?('C:\Ruby-1.9.3-p551\bin\ruby.exe') }
end

directory 'c:\source' do
  action    :delete
  recursive true
end

directory 'C:\Ruby-1.9.3-p551'

windows_batch 'unzip_and_move_ruby' do
  code <<-EOH
  #{node['7-zip']['home']}\\7z.exe x #{Chef::Config[:file_cache_path]}\\ruby-1.9.3-p551-i386-mingw32.7z -oC:\\source -r -y > c:\\7zip.log
  xcopy "C:\\source\\ruby-1.9.3-p551-i386-mingw32\\*" "C:\\Ruby-1.9.3-p551" /e /y /i
  EOH
  creates    'C:\Ruby-1.9.3-p551\bin\ruby.exe'
end

windows_path 'C:\Ruby-1.9.3-p551\bin' do
  action :add
end
