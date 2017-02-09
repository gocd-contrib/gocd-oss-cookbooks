include_recipe 'nodejs'

yum_repository 'yarn' do
  description "Yarn Repository"
  baseurl     "https://dl.yarnpkg.com/rpm/"
  enabled     true
  gpgcheck    true
  gpgkey      'https://dl.yarnpkg.com/rpm/pubkey.gpg'
  action      :create
end

package 'yarn'
