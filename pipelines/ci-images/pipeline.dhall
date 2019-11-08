let Concourse = ../dhall-modules/deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let JSON = Prelude.JSON

let dockerHubUser = "((docker_hub_user))"

let dockerHubPassword = "((docker_hub_password))"

let sendSlackNotification = ../dhall-modules/helpers/slack_on_fail.dhall

let imageResource =
        λ(name : Text)
      → ../dhall-modules/helpers/docker-resource.dhall
          "${name}-image"
          "eirini/${name}"
          (None Text)
          dockerHubUser
          dockerHubPassword

let imageSource =
        λ(name : Text)
      → Concourse.schemas.Resource::{
        , name = "${name}-image-source"
        , type = Concourse.Types.ResourceType.InBuilt "git"
        , icon = Some "git"
        , source =
            Some
              ( toMap
                  { uri =
                      JSON.string
                        "https://github.com/cloudfoundry-incubator/eirini-ci"
                  , branch = JSON.string "master"
                  , paths =
                      JSON.array [ JSON.string "images/${name}/Dockerfile" ]
                  }
              )
        }

let buildImageJob =
        λ(name : Text)
      → let repository = imageSource name
        
        in  Concourse.schemas.Job::{
            , name = "update-${name}-image"
            , plan =
                [ ../dhall-modules/helpers/get-trigger.dhall repository
                , Concourse.helpers.putStep
                    Concourse.schemas.PutStep::{
                    , resource = imageResource name
                    , params =
                        Some
                          ( toMap
                              { build =
                                  JSON.string
                                    "${repository.name}/images/${name}"
                              }
                          )
                    , get_params =
                        Some (toMap { skip_download = JSON.bool True })
                    }
                ]
            , on_failure = sendSlackNotification
            }

let getGolangImage =
      ../dhall-modules/helpers/get-trigger.dhall
        ( ../dhall-modules/helpers/docker-resource-no-creds.dhall
            "golang-image"
            "golang"
            (None Text)
        )

let buildImageWithGolang =
        λ(name : Text)
      → let j = buildImageJob name in j ⫽ { plan = [ getGolangImage ] # j.plan }

let mapToJobs = Prelude.List.map Text Concourse.Types.Job

in    mapToJobs buildImageJob [ "ibmcloud", "scf-builder", "buildah", "dhall" ]
    # mapToJobs buildImageWithGolang [ "gcloud", "ci" ]
