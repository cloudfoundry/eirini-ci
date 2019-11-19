let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let eirini
    : Text → Concourse.Types.Resource
    =   λ(branch : Text)
      →   Concourse.defaults.Resource
        ⫽ { name = "eirini"
          , type = Concourse.Types.ResourceType.InBuilt "git"
          , icon = Some "git"
          , source =
              Some
                ( toMap
                    { uri =
                        Prelude.JSON.string
                          "https://github.com/cloudfoundry-incubator/eirini.git"
                    , branch = Prelude.JSON.string branch
                    , ignore_paths =
                        ../helpers/text-list-to-json.dhall
                          ../facts/non-go-eirini-paths.dhall
                    }
                )
          }

in  eirini
