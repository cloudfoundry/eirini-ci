let Concourse = ../deps/concourse.dhall

let taskFile = ../helpers/task-file.dhall

let iksParams = ../helpers/iks-params.dhall

let ImageLocation = ../types/image-location.dhall

let DeployTaggedRequirements = ../types/deploy-tagged-requirements.dhall

in    λ ( reqs
        : ../types/deployment-requirements.dhall
        )
    → let getUAAReadyEvent =
            ../helpers/get-passed.dhall
              reqs.uaaReadyEvent
              [ "deploy-scf-uaa-${reqs.clusterName}" ]
      
      let deploySCFTaskFile
          : Concourse.Types.TaskSpec
          = merge
              { InRepo =
                  λ(ignored : {}) → taskFile reqs.ciResources "deploy-scf"
              , FromTags =
                    λ ( ignored
                      : DeployTaggedRequirements
                      )
                  → Concourse.Types.TaskSpec.File
                      "${reqs.ciResources.name}/tasks/deploy-scf/task-with-image-overrides.yml"
              }
              reqs.imageLocation
      
      let deploySCF =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "deploy-scf"
              , config = deploySCFTaskFile
              , params =
                  Some
                    ( toMap
                        { CLUSTER_NAME = reqs.clusterName
                        , VERSIONING_CLUSTER = reqs.worldName
                        , USE_CERT_MANAGER = reqs.useCertManager
                        }
                    )
              }
      
      let smokeTestEirini =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "smoke-eirini"
              , config = taskFile reqs.ciResources "eirini-smoke-tests"
              , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
              }
      
      let blockNetworkAccess =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "block-network-access"
              , config = taskFile reqs.ciResources "block-network-access"
              , params =
                  Some
                    ( toMap
                        (   iksParams reqs.iksCreds
                          ⫽ { CLUSTER_NAME = reqs.clusterName }
                        )
                    )
              }
      
      let recheckEirini =
            Concourse.helpers.taskStep
              Concourse.schemas.TaskStep::{
              , task = "recheck-eirini"
              , config = taskFile reqs.ciResources "eirini-smoke-tests"
              , params = Some (toMap { CLUSTER_NAME = reqs.clusterName })
              }
      
      let stepsForInRepo = λ(ignored : {}) → [] : List Concourse.Types.Step
      
      let stepsForTaggedImages =
              λ(tagReqs : DeployTaggedRequirements)
            → [ ../helpers/get-trigger-passed.dhall
                  tagReqs.eiriniRepo
                  [ "tag-images" ]
              , ../helpers/get-passed.dhall
                  tagReqs.deploymentVersion
                  [ "tag-images" ]
              ]
      
      let getImageLocationDependentSteps
          : ImageLocation → List Concourse.Types.Step
          =   λ(imageLocation : ImageLocation)
            → merge
                { InRepo = stepsForInRepo, FromTags = stepsForTaggedImages }
                imageLocation
      
      in  Concourse.schemas.Job::{
          , name = "deploy-scf-eirini-${reqs.clusterName}"
          , serial_groups = Some [ reqs.clusterName ]
          , plan =
                getImageLocationDependentSteps reqs.imageLocation
              # [ ../helpers/get-trigger.dhall reqs.eiriniReleaseResources
                , ../helpers/get.dhall reqs.ciResources
                , ../helpers/get-named.dhall reqs.clusterState "state"
                , getUAAReadyEvent
                , reqs.downloadKubeconfigTask
                , deploySCF
                , smokeTestEirini
                , blockNetworkAccess
                , recheckEirini
                ]
          }
