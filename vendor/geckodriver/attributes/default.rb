default['geckodriver']['version'] = 'v0.14.0'
default['geckodriver']['url'] = 'https://github.com/mozilla/geckodriver/releases/download'

default['geckodriver']['windows']['home'] = "#{ENV['SYSTEMDRIVE']}/geckodriver"
default['geckodriver']['unix']['home'] = '/opt/geckodriver'

default['geckodriver']['home'] = if platform?('windows')
                                   node['geckodriver']['windows']['home']
                                 else
                                   node['geckodriver']['unix']['home']
                                 end
