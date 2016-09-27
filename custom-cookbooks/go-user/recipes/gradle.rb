# ensure that gradle is installed in `/go/.gradle` via gradle-wrapper
include_recipe 'java'

directory '/go/.gradle' do
  owner 'go'
  group 'go'
  mode  '0755'
end

cookbook_file '/go/.gradle/init.gradle' do
  owner 'go'
  group 'go'
  mode  '0600'
end

remote_file '/tmp/gradlew' do
  owner 'root'
  group 'root'
  mode '0755'
  source 'https://raw.githubusercontent.com/gocd/gocd/master/gradlew'
end

directory '/tmp/gradle' do
  owner 'go'
  group 'go'
  mode '0755'
end

directory '/tmp/gradle/wrapper' do
  owner 'go'
  group 'go'
  mode '0755'
end

%w(gradlew gradle/wrapper/gradle-wrapper.properties gradle/wrapper/gradle-wrapper.jar).each do |f|
  remote_file "/tmp/#{f}" do
    owner 'go'
    group 'go'
    mode '0755'
    source "https://raw.githubusercontent.com/gocd/gocd/master/#{f}"
  end
end

execute '/tmp/gradlew --version > /dev/null 2>&1' do
  user 'go'
  group 'go'
  environment('HOME' => '/go',
              'USER' => 'go')
end
