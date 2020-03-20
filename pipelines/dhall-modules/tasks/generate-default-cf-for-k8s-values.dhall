let Concourse = ../deps/concourse.dhall

let task =
        λ(cfForK8s : Concourse.Types.Resource)
      → λ(clusterName : Text)
      → λ(creds : ../types/creds.dhall)
      → let script =
              ''
              set -euo pipefail
              export KUBECONFIG="$PWD/kube/config"
              echo $GCP_SERVICE_ACCOUNT > account.json
              export GCP_SERVICE_ACCOUNT_JSON=$PWD/account.json

              "${cfForK8s.name}"/hack/generate-values.sh "${clusterName}".ci-envs.eirini.cf-app.com > default-values-file/values.yml
              ''

        let IKSCreds = ../types/iks-creds.dhall

        let GKECreds = ../types/gke-creds.dhall

        let cloudParams =
              merge
                { IKSCreds =
                      λ(c : IKSCreds)
                    → toMap
                        { IBMCLOUD_ACCOUNT = c.account
                        , IBMCLOUD_USER = c.user
                        , IBMCLOUD_PASSWORD = c.password
                        }
                , GKECreds =
                      λ(c : GKECreds)
                    → toMap { GCP_SERVICE_ACCOUNT = c.serviceAccountJSON }
                }
                creds

        in  Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "generate default values"
              , config =
                  Concourse.Types.TaskSpec.Config
                    Concourse.schemas.TaskConfig::{
                    , image_resource =
                        ../helpers/image-resource.dhall
                          "relintdockerhubpushbot/cf-for-k8s-ci"
                    , inputs =
                        Some
                          [ Concourse.schemas.TaskInput::{
                            , name = cfForK8s.name
                            }
                          , Concourse.schemas.TaskInput::{ name = "kube" }
                          ]
                    , outputs =
                        Some
                          [ Concourse.schemas.TaskOutput::{
                            , name = "default-values-file"
                            }
                          ]
                    , run = ../helpers/bash-script-task.dhall script
                    }
              , params = Some cloudParams
              }

in  task
