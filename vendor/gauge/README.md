Gauge Cookbook
==============
[Gauge](http://getgauge.io/) Test automation in the business language (from ThoughtWorks, Inc.)

Requirements
============

## Supported Platforms

This cookbook has been tested on the following platforms:

* CentOS
* RedHat
* Fedora
* Amazon Linux
* Oracle Linux
* Debian
* Ubuntu
* openSUSE
* SUSE

Usage
=====

Include the default recipe on a node's runlist to ensure that gauge is installed.

Attributes
----------
```
node['gauge']['version'] # the version of gauge that should be installed
node['gauge']['checksum'] # the sha256 checksum of the gauge binary that should be installed (computed using 'sha256sum')
node['gauge']['url'] # the URL from which gauge binary should be download from
```
Setting up Gauge properties
[Gauge Docs - Configuration](http://getgauge.io/documentation/user/current/advanced_readings/configuration/)

gauge.properties
----------
[Source](https://docs.getgauge.io/configuration.html?highlight=properties)
```
# Timeout in milliseconds for making a connection to the language runner.
node['gauge']['properties']['runner_connection_timeout']

# Timeout in milliseconds for making a connection to plugins.
node['gauge']['properties']['plugin_connection_timeout']

# Timeout in milliseconds for a plugin to stop after a kill message has been sent.
node['gauge']['properties']['plugin_kill_timeout']

# Timeout in milliseconds for requests from the language runner.
node['gauge']['properties']['runner_request_timeout']

# Allow Gauge and its plugin updates to be notified.
node['gauge']['properties']['check_updates']
```
Resources/Providers
-------------------

### `gauge_plugin`

This LWRP provides an easy way to manage additional gauge plugins.

#### Actions

- `:install` - installs a gauge plugin
- `:remove` - removes the gauge plugin

#### Attribute Parameters

- `name` - the name of the plugin
- `version` - the version of the plugin
- `user` - the user under which the plugin should be installed
- `group` - the group under which the plugin should be installed
- `password` - needed only for windows, the windows account password for `user`

#### Examples

Install the gauge `java` plugin

```ruby
include_recipe 'gauge'

gauge_plugin 'java' do
  user  'alice'
  group 'alice'
  password 'p@ssw0rd' # only on windows
  version '0.3.1'
end
```

Remove the gauge `html-report` plugin

```ruby
gauge_plugin 'html-report' do
  action :remove
  user  'alice'
  group 'alice'
end
```
