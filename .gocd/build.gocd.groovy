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

          secureEnvironmentVariables = [
            DOCKERHUB_USERNAME: 'AES:C6gaOdyi+SDGkkvUHni6zw==:I2kqDgvf9GiwD7zzT1UWjQ==',
            DOCKERHUB_PASSWORD: 'AES:B2dXEmk4/HMqgLITXECK2A==:dfe+7OkQVOss4fFcXbACy1ZMqW8kVWvt8jyMmgzMDb8='
          ]
          
          jobs {
            job('centos-6') {
              elasticProfileId = 'ecs-dind-gocd-agent'
              tasks {
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