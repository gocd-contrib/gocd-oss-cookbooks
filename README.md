#### Images built:

- `gocddev/gocd-dev-build:centos-6-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-<github_tag>`

To build images a new image, create a new tag and push to this repository.

#### Build an image locally

`docker build . -t gocddev/gocd-dev-build:centos6-v2.0.29 -f Dockerfile.centos6`
`docker build . -t gocddev/gocd-dev-build:centos7-v2.0.29 -f Dockerfile.centos7`

#### Upgrading a vendor cookbook

If the cookbook is specified under Berksfile, then, 

`berks update <cookbook_name_as_specified_in_metadata>; berks vendor vendor`

_Note: Check in the Berksfile.lock._

If a vendor cookbook that's been checked in is not present in Berksfile, then add it to the Berksfile and run the above command.

Alternatively, you could download a newer version of the cookbook from the chef supermarket and check that in. However, if the vendor cookbook has dependencies, then, those need to be updated and checked in as well.