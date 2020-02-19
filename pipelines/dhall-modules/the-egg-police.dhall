let Concourse = ./deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let JSON = Prelude.JSON

let theEggPolice =
        λ(eiriniRelease : Concourse.Types.Resource)
      → λ(githubPrivateKey : Text)
      → let every30seconds =
                Concourse.defaults.Resource
              ⫽ { name = "every-30-seconds"
                , type = Concourse.Types.ResourceType.InBuilt "time"
                , icon = Some "timer"
                , source = Some (toMap { interval = JSON.string "30s" })
                }

        let lock =
              ../dhall-modules/resources/lock.dhall
                "the-egg-police"
                githubPrivateKey

        let upstream = [ "the-egg-police 🚓" ]

        let lockJobs =
              ./locks.dhall
                { upstream = upstream
                , lockResource = lock
                , eiriniReleaseRepo = eiriniRelease
                , acquireLockGetTriggers =
                    [ ./helpers/get-trigger.dhall every30seconds ]
                }

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
                          ../dhall-modules/helpers/bash-script-task.dhall
                            ''
                            set -euo pipefail

                            curl --fail https://retro.acceptance.eu-gb.containers.appdomain.cloud
                            ''
                      }
                }

        let eggJob =
              Concourse.schemas.Job::{
              , name = "the-egg-police 🚓"
              , serial = Some True
              , plan =
                  [ ../dhall-modules/helpers/get-trigger-passed.dhall
                      lock
                      [ lock.name ]
                  , ../dhall-modules/helpers/get.dhall eiriniRelease
                  , curlEggTask
                  ]
              }

        in  lockJobs # [ ./helpers/group-job.dhall [ "egg" ] eggJob ]

in  theEggPolice
