# ensure that gradle is installed in `/go/.gradle` via gradle-wrapper
include_recipe 'java'
include_recipe 'git'

if node['platform_family'] == 'windows'
  include_recipe 'nodejs-windows'
else
  include_recipe 'nodejs'
  include_recipe 'yarn'
end

gocd_path = node['platform_family'] == 'windows' ? 'c:\gocd' : '/tmp/gocd'

execute "git clone https://github.com/gocd/gocd --depth 1 --quiet #{gocd_path}" do
  unless node['platform_family'] == 'windows'
    user  'go'
    group 'go'
    environment('HOME' => '/go',
                'USER' => 'go')
  end
end

gradle_executable = if node['platform_family'] == 'windows'
  'gradlew.bat'
else
  './gradlew'
end

gradle_command = "#{gradle_executable} prepare compileTestJava --max-workers 4 --no-daemon"
unless node['platform_family'] == 'windows'
  gradle_command = ['bash', '-lc', gradle_command]
end

execute "prep gradle" do
  cwd gocd_path
  command gradle_command
  unless node['platform_family'] == 'windows'
    user  'go'
    group 'go'
    environment('HOME' => '/go',
                'USER' => 'go')
  end
end

directory gocd_path do
  action :delete
  recursive true

  retries 5
  retry_delay 2
end

directory ::File.join(node['go-user']['home_dir'], '.gradle') do
  unless node['platform_family'] == 'windows'
    owner 'go'
    group 'go'
    mode  '0755'
  end
end

cookbook_file ::File.join(node['go-user']['home_dir'], '.gradle', 'init.gradle') do
  unless node['platform_family'] == 'windows'
    owner 'go'
    group 'go'
    mode  '0600'
  end
end
