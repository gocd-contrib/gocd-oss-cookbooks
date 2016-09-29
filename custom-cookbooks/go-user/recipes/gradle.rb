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

bash 'initialize gocd build' do
  user  'go'
  group 'go'
  environment('HOME' => '/go',
              'USER' => 'go')
  code "
    source /etc/bashrc
    source /etc/profile

    cd /tmp
    git clone https://github.com/gocd/gocd --depth 1 --quiet
    cd gocd
    ./gradlew clean prepare --max-workers 4 > /dev/null 2>&1
    cd /
    rm -rf /tmp/gocd
  "
end
