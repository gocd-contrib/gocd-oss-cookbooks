# NSIS Cookbook

[NSIS](http://nsis.sourceforge.net/) - A scriptable win32 installer/uninstaller system.


# Requirements

## Platforms

* CentOS/RedHat (may perhaps work with other RPM distros, but is not tested)

## Dependent Cookbooks

* yum


# Usage

## Recipes

* default - Include the default recipe on a node's runlist to ensure that NSIS is installed.

## Attributes

The following attributes can be used to change behavior:

* ```node['nsis']['version']```
    - Setting it to "latest" (default) always upgrades nsis to the latest available revision in the repository.
    - It can be set to any available version (such as: "2.50-15.el6") to pin it to that revision.


# Contributing

We encourage you to contribute to GoCD. For information on contributing to this
project, please see our [contributor's guide](http://www.go.cd/contribute).  A
lot of useful information like links to user documentation, design
documentation, mailing lists etc. can be found in the
[resources](http://www.go.cd/community/resources.html) section.

## License

```plain
Copyright 2016 ThoughtWorks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
