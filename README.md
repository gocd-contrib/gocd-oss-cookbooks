# Images built:

- `gocddev/gocd-dev-build:centos-6-<github_tag>`
- `gocddev/gocd-dev-build:centos-7-<github_tag>`
- `gocddev/gocd-dev-build:windows-<github_tag>`
- `gocddev/gocd-dev-build-dind:<gocd-version>`

To build images a new image, create a new tag and push to this repository.

# Build an image locally

- ```docker build . -t gocddev/gocd-dev-build:centos6-v2.0.29 -f Dockerfile.centos6```
- ```docker build . -t gocddev/gocd-dev-build:centos7-v2.0.29 -f Dockerfile.centos7```
- ```docker build . -t gocddev/gocd-dev-build:windows-v2.0.29 -f Dockerfile.windowsservercore```
- ```docker build . -t gocddev/gocd-dev-build-dind:19.1.0 -f Dockerfile.dind```

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
