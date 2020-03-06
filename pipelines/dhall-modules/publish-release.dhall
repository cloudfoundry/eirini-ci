let Concourse = ../dhall-modules/deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let JSON = Prelude.JSON

let PublishReleaseRequirements = ./types/publish-release-requirements.dhall

let publishReleaseJobs =
        λ(reqs : PublishReleaseRequirements)
      → let githubAccessTask =
                λ(name : Text)
              → Concourse.helpers.taskStep
                  Concourse.schemas.TaskStep::{
                  , task = name
                  , config = ./helpers/task-file.dhall reqs.ciResources name
                  , params =
                      Some (toMap { GITHUB_TOKEN = reqs.githubAccessToken })
                  }

        let boringTask
            : Text → Concourse.Types.Step
            =   λ(name : Text)
              → Concourse.helpers.taskStep
                  Concourse.schemas.TaskStep::{
                  , task = name
                  , config = ./helpers/task-file.dhall reqs.ciResources name
                  }

        let putScfRelease =
              Concourse.helpers.putStep
                Concourse.schemas.PutStep::{
                , resource = reqs.githubRelease
                , params =
                    Some
                      ( toMap
                          { name =
                              JSON.string "${reqs.versionResource.name}/version"
                          , tag =
                              JSON.string "${reqs.versionResource.name}/version"
                          , tag_prefix = JSON.string "v"
                          , globs =
                              ./helpers/text-list-to-json.dhall
                                [ "release-output/eirini*.tgz" ]
                          }
                      )
                }

        let putGhPagesPr =
              Concourse.helpers.putStep
                Concourse.schemas.PutStep::{
                , resource = reqs.ghPagesRepo
                , params =
                    Some (toMap { repository = JSON.string "gh-pages-updated" })
                }

        let tagSteps =
              ./jobs/steps/tag-repo.dhall reqs.ciResources reqs.versionResource

        let publishReleaseJob =
              Concourse.schemas.Job::{
              , name = "publish-release"
              , plan =
                    [ ./helpers/get.dhall reqs.ciResources
                    , ./helpers/get.dhall reqs.ghPagesRepo
                    , githubAccessTask "check-for-pending-release"
                    , ./helpers/get-named.dhall reqs.clusterState "state"
                    , ./helpers/get-passed.dhall
                        reqs.eiriniReleaseRepo
                        [ "run-smoke-tests-acceptance", "the-egg-police 🚓", "smoke-tests-cf4k8s4a8e" ]
                    , ./helpers/get.dhall reqs.versionResource
                    , boringTask "create-release"
                    , boringTask "update-helm-repo"
                    , putScfRelease
                    , putGhPagesPr
                    , githubAccessTask "create-github-pr"
                    ]
                  # tagSteps reqs.writeableEiriniRepo "opi" "opi"
                  # tagSteps
                      reqs.writeableStagingRepo
                      "staging-downloader"
                      "recipe-downloader"
              }

        let AutoBumpVersion = ./types/auto-bump-version.dhall

        let bumpMajor =
              ./jobs/bump-version.dhall
                reqs.versionResource
                "major"
                AutoBumpVersion.NoAutoBump

        let bumpMinor =
              ./jobs/bump-version.dhall
                reqs.versionResource
                "minor"
                (AutoBumpVersion.AutoBumpOn publishReleaseJob.name)

        let jobs = [ bumpMinor, bumpMajor, publishReleaseJob ]

        in  ./helpers/group-jobs.dhall [ "publish-release" ] jobs

in  publishReleaseJobs
