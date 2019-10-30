let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let eiriniStaging =
        Concourse.defaults.Resource
      ⫽ { name =
            "eirini-staging"
        , type = Concourse.Types.ResourceType.InBuilt "git"
        , icon = Some "git"
        , source =
            Some
              ( toMap
                  { uri =
                      Prelude.JSON.string
                        "https://github.com/cloudfoundry-incubator/eirini-staging.git"
                  , branch = Prelude.JSON.string "master"
                  }
              )
        }

in  eiriniStaging
