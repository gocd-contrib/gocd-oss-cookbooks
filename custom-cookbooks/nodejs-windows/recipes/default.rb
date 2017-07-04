include_recipe 'chocolatey'

chocolatey_package 'nodejs.install' do
  version node['nodejs']['version']
end

chocolatey_package 'yarn'

chocolatey_package 'python2' # needed by node-gyp for native compilation
chocolatey_package 'vcbuildtools'
chocolatey_package 'microsoft-build-tools'

execute '"C:\Program Files\nodejs\npm.cmd" config set msvs_version 2015'
