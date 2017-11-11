default['chromedriver']['version'] = 'LATEST_RELEASE'
default['chromedriver']['url'] = 'https://chromedriver.storage.googleapis.com'

default['chromedriver']['windows']['home'] = "#{ENV['SYSTEMDRIVE']}/chromedriver"
default['chromedriver']['unix']['home'] = '/opt/chromedriver'
