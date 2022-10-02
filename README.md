# Images built:

- `gocddev/gocd-dev-build:dind-<github_tag>`
- `gocddev/gocd-dev-build:centos-9-<github_tag>`
- `gocddev/gocd-dev-build:ubuntu-22-04-<github_tag>`
- `gocddev/gocd-dev-build:windows2022-<github_tag>`

To build a new version of the images, push a new version tag to this repository.

# Build an image locally

- ```docker build . -t gocddev/gocd-dev-build:dind-SNAPSHOT -f dind.Dockerfile```
- ```docker build . -t gocddev/gocd-dev-build:centos-9-SNAPSHOT -f centos.Dockerfile```
- ```docker build . -t gocddev/gocd-dev-build:ubuntu-22-04-SNAPSHOT -f ubuntu.Dockerfile```
- ```docker build . -t gocddev/gocd-dev-build:windows2022-SNAPSHOT -f windowsservercore.Dockerfile```


# Publish

To publish a new image - add a new tag to the repository. The workflow will be triggered which will publish the image to [docker hub](https://hub.docker.com/r/gocddev/gocd-dev-build).

# License

```plain
Copyright 2022 Thoughtworks, Inc.

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
