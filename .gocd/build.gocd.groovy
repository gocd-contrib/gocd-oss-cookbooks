import cd.go.contrib.plugins.configrepo.groovy.dsl.*


GoCD.script {
  pipelines {
    pipeline('build-dev-images') {
      group = 'internal'
      materials {
        git {
          url = 'https://github.com/gocd-contrib/gocd-oss-cookbooks'
        }
      }

      stages {
        stage('deploy') {
          approval {
            type = 'manual'
          }

          environmentVariables = [
            DOCKERHUB_USERNAME: '{{SECRET:[build-pipelines][DOCKERHUB_USER]}}',
            DOCKERHUB_PASSWORD: '{{SECRET:[build-pipelines][DOCKERHUB_PASS]}}'
          ]

          jobs {
            job('dind') {
              elasticProfileId = 'ecs-dind-gocd-agent'
              tasks {
                bash{
                  commandString='if [ $(git tag --points-at HEAD --sort=version:refname | tail -n1 | wc -c) == 0 ]; then echo "Please set a tag pointing to the HEAD"; exit 1; fi'
                }
                bash {
                  commandString = 'echo "${DOCKERHUB_PASSWORD}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin'
                }
                bash {
                  commandString = 'set -x; git fetch --all; docker build -f Dockerfile.dind -t gocddev/gocd-dev-build:dind-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)" .'
                }
                bash {
                  commandString = 'docker push gocddev/gocd-dev-build:dind-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)"'
                }
              }
            }
            job('centos-6') {
              elasticProfileId = 'ecs-dind-gocd-agent'
              tasks {
                bash{
                  commandString='if [ $(git tag --points-at HEAD --sort=version:refname | tail -n1 | wc -c) == 0 ]; then echo "Please set a tag pointing to the HEAD"; exit 1; fi'
                }
                bash {
                  commandString = 'echo "${DOCKERHUB_PASSWORD}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin'
                }
                bash {
                  commandString = 'set -x; git fetch --all; docker build -f Dockerfile.centos6 -t gocddev/gocd-dev-build:centos-6-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)" .'
                }
                bash {
                  commandString = 'docker push gocddev/gocd-dev-build:centos-6-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)"'
                }
              }
            }
            job('centos-7') {
              elasticProfileId = 'ecs-dind-gocd-agent'
              tasks {
                bash{
                  commandString='if [ $(git tag --points-at HEAD --sort=version:refname | tail -n1 | wc -c) == 0 ]; then echo "Please set a tag pointing to the HEAD"; exit 1; fi'
                }
                bash {
                  commandString = 'echo "${DOCKERHUB_PASSWORD}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin'
                }

                bash {
                  commandString = 'set -x; git fetch --all; docker build -f Dockerfile.centos7 -t gocddev/gocd-dev-build:centos-7-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)" .'
                }

                bash {
                  commandString = 'docker push gocddev/gocd-dev-build:centos-7-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)"'
                }
              }
            }
            job('ubuntu-16.04') {
              elasticProfileId = 'ecs-dind-gocd-agent'
              tasks {
                bash{
                  commandString='if [ $(git tag --points-at HEAD --sort=version:refname | tail -n1 | wc -c) == 0 ]; then echo "Please set a tag pointing to the HEAD"; exit 1; fi'
                }
                bash {
                  commandString = 'echo "${DOCKERHUB_PASSWORD}" | docker login --username "${DOCKERHUB_USERNAME}" --password-stdin'
                }

                bash {
                  commandString = 'set -x; git fetch --all; docker build -f Dockerfile.ubuntu -t gocddev/gocd-dev-build:ubuntu-16-04-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)" .'
                }

                bash {
                  commandString = 'docker push gocddev/gocd-dev-build:ubuntu-16-04-"$(git tag --points-at HEAD --sort=version:refname | tail -n1)"'
                }
              }
            }
            job('windows-2016') {
              elasticProfileId = 'azure-windows-server-container'
              timeout = 90
              tasks {
                exec{
                  commandLine=['powershell','if ($(git tag --points-at HEAD --sort=version:refname | tail -n1).length -eq 0) { echo "Please set a tag pointing to the HEAD"; exit 1; }']
                }
                exec {
                  commandLine = ['powershell', 'docker login --username "%DOCKERHUB_USERNAME%" --password "%DOCKERHUB_PASSWORD%"']
                }
                exec {
                  commandLine = ['powershell', 'git fetch --all']
                }
                exec {
                  commandLine = ['powershell', 'docker build -f Dockerfile.windowsservercore2016 -t gocddev/gocd-dev-build:windows2016-$(git tag --points-at HEAD --sort=version:refname | tail -n1) .']
                }
                exec {
                  commandLine = ['powershell', 'docker push gocddev/gocd-dev-build:windows2016-$(git tag --points-at HEAD --sort=version:refname | tail -n1)']
                }
              }
            }
          }
        }
      }
    }
  }

  environments {
    environment('internal') {
      pipelines = ['build-dev-images']
    }
  }

}
