let Concourse = ../dhall-modules/deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let JSON = (../dhall-modules/deps/prelude.dhall).JSON

let inputs = { githubPrivateKey = "((github-private-key))" }

let every30seconds =
        Concourse.defaults.Resource
      ⫽ { name = "every-30-seconds"
        , type = Concourse.Types.ResourceType.InBuilt "time"
        , icon = Some "timer"
        , source = Some (toMap { interval = Prelude.JSON.string "30s" })
        }

let lock =
      ../dhall-modules/resources/lock.dhall
        "the-egg-police"
        inputs.githubPrivateKey

let lockJob =
      Concourse.schemas.Job::{
      , name = lock.name
      , serial = Some True
      , plan =
          [ ../dhall-modules/helpers/get-trigger.dhall every30seconds
          , Concourse.helpers.putStep
              Concourse.schemas.PutStep::{
              , resource = lock
              , params = Some (toMap { acquire = JSON.bool True })
              }
          ]
      }

let upstream = [ "the-egg-police 🚓" ]

let eiriniReleaseRepo =
      ../dhall-modules/resources/eirini-release.dhall "develop"

let unlockJob =
      ../dhall-modules/jobs/unlock.dhall eiriniReleaseRepo upstream lock

let releaseLocks = ../dhall-modules/jobs/release-lock.dhall lock

let lockJobs = [ lockJob, unlockJob, releaseLocks ]

let curlEggTask =
      Concourse.helpers.taskStep
        Concourse.schemas.TaskStep::{
        , task = "curl-egg"
        , config =
            Concourse.Types.TaskSpec.Config
              Concourse.schemas.TaskConfig::{
              , image_resource =
                  ../dhall-modules/helpers/image-resource.dhall
                    "eirini/ibmcloud"
              , run =
                  Concourse.schemas.TaskRunConfig::{
                  , path = "bash"
                  , args =
                      Some
                        [ "-c"
                        , ''
                          set -euo pipefail

                          curl https://retro.acceptance.eu-gb.containers.appdomain.cloud
                          ''
                        ]
                  }
              }
        }

let theEggPolice =
      Concourse.schemas.Job::{
      , name = "the-egg-police 🚓"
      , serial = Some True
      , plan =
          [ ../dhall-modules/helpers/get-trigger-passed.dhall lock [ lock.name ]
          , ../dhall-modules/helpers/get.dhall eiriniReleaseRepo
          , curlEggTask
          ]
      }

let jobs =
      Prelude.List.concat
        Concourse.Types.GroupedJob
        [ [ ../dhall-modules/helpers/group-job.dhall [ "egg" ] theEggPolice ]
        , ../dhall-modules/helpers/group-jobs.dhall [ "locky-unlocky" ] lockJobs
        ]

in  jobs
