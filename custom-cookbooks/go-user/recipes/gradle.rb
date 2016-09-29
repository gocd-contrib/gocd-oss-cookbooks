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
  cmd "
    source /etc/bashrc
    source /etc/profile

    cd /tmp
    git clone https://github.com/gocd/gocd --depth 1 --quiet
    cd gocd
    ./gradlew clean -q prepare --max-workers > /dev/null
    cd /
    rm -rf /tmp/gocd
  "
end
