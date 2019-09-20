# Images built:

- `gocddev/gocd-dev-build:dind-<github_tag>`
- `gocddev/gocd-dev-build:centos-6-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-<github_tag>`
- `gocddev/gocd-dev-build:ubuntu-16-04-<github_tag>`
- `gocddev/gocd-dev-build:windows2016-<github_tag>`

To build images a new image, create a new tag and push to this repository.

# Build an image locally

- ```docker build . -t gocddev/gocd-dev-build:dind-SNAPSHOT -f Dockerfile.dind```
- ```docker build . -t gocddev/gocd-dev-build:centos-6-SNAPSHOT -f Dockerfile.centos6```
- ```docker build . -t gocddev/gocd-dev-build:centos-7-SNAPSHOT -f Dockerfile.centos7```
- ```docker build . -t gocddev/gocd-dev-build:ubuntu-16-04-SNAPSHOT -f Dockerfile.ubuntu```
- ```docker build . -t gocddev/gocd-dev-build:windows2016-SNAPSHOT -f Dockerfile.windowsservercore2016```

# License

```plain
Copyright 2019 ThoughtWorks, Inc.

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
