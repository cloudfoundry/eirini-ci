let Concourse = ../deps/concourse.dhall

let KubeCFDeploymentRequirements = ../types/kubecf-deployment-requirements.dhall

in    λ(reqs : KubeCFDeploymentRequirements)
    → let downloadKubeConfig =
            ../tasks/download-kubeconfig.dhall
              reqs.ciResources
              reqs.clusterName
              reqs.creds

      let lockSteps =
            ./steps/lock-steps.dhall
              reqs.lockResource
              [ "generate-kubecf-${reqs.clusterName}" ]

      let clusterReadyEvent =
            Optional/fold
              Concourse.Types.Resource
              reqs.clusterReadyEvent
              (List Concourse.Types.Step)
              (   λ(resource : Concourse.Types.Resource)
                → [ ../helpers/get-trigger-passed.dhall
                      resource
                      [ "generate-kubecf-${reqs.clusterName}" ]
                  ]
              )
              ([] : List Concourse.Types.Step)

      let deleteKubecf =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "delete-kubecf"
              , config =
                  ../helpers/task-file.dhall reqs.ciResources "kubecf/delete"
              }

      let deployKubecf =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "deploy-kubecf"
              , config =
                  ../helpers/task-file.dhall reqs.ciResources "kubecf/deploy"
              , params =
                  Some
                    ( toMap
                        { CLUSTER_NAME = reqs.clusterName
                        , CF_OPERATOR_CHART_URL = reqs.cfOperatorChartUrl
                        }
                    )
              }

      let deployKubecfJob =
            Concourse.schemas.Job::{
            , name = "deploy-kubecf-${reqs.clusterName}"
            , serial_groups = Some [ reqs.clusterName ]
            , public = Some True
            , plan =
                  lockSteps
                # [ ../helpers/get.dhall reqs.ciResources
                  , ../helpers/get-trigger-passed.dhall
                      reqs.eiriniRelease
                      [ "generate-kubecf-${reqs.clusterName}" ]
                  , ../helpers/get-trigger-passed.dhall
                      reqs.kubecfRepo
                      [ "generate-kubecf-${reqs.clusterName}" ]
                  , ../helpers/get.dhall reqs.clusterState
                  ]
                # clusterReadyEvent
                # [ downloadKubeConfig, deleteKubecf, deployKubecf ]
            }

      in  ../helpers/group-job.dhall
            [ "kubecf-${reqs.clusterName}" ]
            deployKubecfJob
