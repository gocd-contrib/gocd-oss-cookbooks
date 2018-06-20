Gauge Cookbook
==============
[Gauge](http://getgauge.io/) Test automation in the business language (from ThoughtWorks, Inc.)

Requirements
============

## Supported Platforms

This cookbook has been tested on the following platforms:

* CentOS
* RedHat
* Debian
* Ubuntu


Usage
=====

Include the default recipe on a node's runlist to ensure that gauge is installed.

Attributes
----------
```
node['gauge']['version'] # the version of gauge that should be installed
```
Setting up Gauge properties
Gauge properties are no longer managed by this cookbook. Please refer to [Gauge Docs - Configuration](https://docs.gauge.org/master/configuration.html#configuration) for managing properties



