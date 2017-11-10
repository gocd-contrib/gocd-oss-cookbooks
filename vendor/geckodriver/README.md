# Selenium GeckoDriver Cookbook

[![Cookbook Version](http://img.shields.io/cookbook/v/geckodriver.svg?style=flat-square)][cookbook]
[![linux](http://img.shields.io/travis/dhoer/chef-geckodriver/master.svg?label=linux&style=flat-square)][linux]
[![osx](http://img.shields.io/travis/dhoer/chef-geckodriver/macosx.svg?label=macosx&style=flat-square)][osx]
[![win](https://img.shields.io/appveyor/ci/dhoer/chef-geckodriver/master.svg?label=windows&style=flat-square)][win]

[cookbook]: https://supermarket.chef.io/cookbooks/geckodriver
[linux]: https://travis-ci.org/dhoer/chef-geckodriver
[osx]: https://travis-ci.org/dhoer/chef-geckodriver/branches
[win]: https://ci.appveyor.com/project/dhoer/chef-geckodriver

Installs geckodriver (https://github.com/mozilla/geckodriver). 

## Requirements

- Chef 12.6+
- Mozilla Firefox (this cookbook does not install Mozilla Firefox)

### Platforms

- CentOS, RedHat, Fedora
- Mac OS X
- Ubuntu, Debian
- Windows

## Usage

Include recipe in a run list or cookbook to install geckodriver.

### Attributes

- `node['geckodriver']['version']` - Version to download. 
- `node['geckodriver']['url']` -  URL download prefix. 
- `node['geckodriver']['windows']['home']` - Home directory for windows. 
- `node['geckodriver']['unix']['home']` - Home directory for both linux and macosx. 

#### Install selenium node with firefox capability

```ruby
include_recipe 'mozilla_firefox'
include_recipe 'geckodriver'

node.override['selenium']['node']['capabilities'] = [
  {
    browserName: 'firefox',
    maxInstances: 1,
    version: firefox_version,
    seleniumProtocol: 'WebDriver'
  }
]

include_recipe 'selenium::node'
```

## Getting Help

- Ask specific questions on [Stack Overflow](http://stackoverflow.com/questions/tagged/marionette+driver).
- Report bugs and discuss potential features in [Github issues](https://github.com/dhoer/chef-geckodriver/issues).

## Contributing

Please refer to [CONTRIBUTING](https://github.com/dhoer/chef-geckodriver/graphs/contributors).

## License

MIT - see the accompanying [LICENSE](https://github.com/dhoer/chef-geckodriver/blob/master/LICENSE.md) file for 
details.
