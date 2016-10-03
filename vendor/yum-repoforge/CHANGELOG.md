# yum-repoforge Cookbook CHANGELOG

This file is used to list changes made in each version of the yum-repoforge cookbook.

## 1.0.0 (2016-09-06)
- Add chef_version to the metadata
- Testing updates
- Remove Chef 11 support

## v0.7.1 (2016-08-18)

- Fix support for Amazon 2016 releases
- Remove bats integration testing

## v0.7.0 (2016-04-27)

- Add support for Amazon 2016 releases to the extras repo

## v0.6.0 (2016-03-23)

- Add support for the 2016 Amazon releases

## v0.5.7 (2015-12-09)

- Fixing minor typo: nil -> nil?

## v0.5.6 (2015-12-09)

- Adding unless nil checks to properties in recipe to avoid Chef 13 deprecation warnings

## v0.5.5

- No changes... accidental release number mistake

## v0.5.4 (2015-09-21)

- Added Chef standard Rubocop file and resolved all warnings
- Added Kitchen CI platforms
- Add supported platforms to the metadata
- Fixed the package install test bats file to pass
- Added Chef standard chefignore and .gitignore files
- Updated Berksfile to 3.X format
- Updated and expanded development dependencies in the Gemfile
- Added contributing, testing, and maintainers docs
- Added platform requirements to the readme
- Added Travis and cookbook version badges to the readme
- Update Chefspec to 4.X format

## v0.5.3 (2015-06-21)

- Updating to depend on yum ~> 3.2

## v0.5.2 (2015-06-21)

- Support for EL7

## v0.5.1 (2015-04-15)

- Amazon Linux 2015.03

## v0.5.0 (2014-01-07)

- Adding centos-7 support

## v0.4.0 (2014-09-02)

- Add all attribute available to LWRP to allow for tuning

## v0.3.0 (2014-06-11)

# 1 - Support for Amazon Linux 2014.03

## v0.2.0 (2014-02-14)

- Updating test harness

## v0.1.4

Adding CHANGELOG.md

## v0.1.0

initial release
