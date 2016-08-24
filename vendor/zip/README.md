# chef-zip

## Description

Installs [zip and unzip](http://packages.ubuntu.com/lucid/unzip). With the exception of multi-volume archives (ie, .ZIP files that are split across several disks using PKZIP's /& option), this can handle any file produced either by PKZIP, or the corresponding InfoZIP zip program.


## Requirements

### Supported Platforms

The following platforms are supported by this cookbook, meaning that the recipes run on these platforms without error:

* Ubuntu
* RHEL
* Fedora


## Recipes

* `zip` - Default recipe


## Usage

This cookbook installs the zip components if not present, and pulls updates if they are installed on the system.


## Attributes

None


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Contributors

Many thanks go to the following who have contributed to making this cookbook even better:

* **[@goruha](https://github.com/goruha)**
    * add support for RHEL and CentOS platforms


## License

**chef-zip**

* Freely distributable and licensed under the [MIT license](http://phlipper.mit-license.org/2011-2013/license.html).
* Copyright (c) 2011-2013 Phil Cohen (github@phlippers.net) [![endorse](http://api.coderwall.com/phlipper/endorsecount.png)](http://coderwall.com/phlipper)
* http://phlippers.net/
