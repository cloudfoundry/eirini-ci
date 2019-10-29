let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

in    λ ( branch
        : Text
        )
    →   Concourse.defaults.Resource
      ⫽ { name =
            "scf-uaa-resources"
        , type = Concourse.Types.ResourceType.InBuilt "git"
        , icon = Some "git"
        , source =
            Some
              ( toMap
                  { uri =
                      Prelude.JSON.string
                        "https://github.com/cloudfoundry-incubator/eirini-release.git"
                  , branch = Prelude.JSON.string branch
                  , paths =
                      Prelude.JSON.array [ Prelude.JSON.string "helm/uaa" ]
                  }
              )
        }
