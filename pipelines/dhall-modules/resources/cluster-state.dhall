let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let clusterState
    : Text → Concourse.Types.Resource
    =   λ ( privateKey
          : Text
          )
      →   Concourse.defaults.Resource
        ⫽ { name =
              "cluster-state"
          , type = Concourse.Types.ResourceType.InBuilt "git"
          , icon = Some "folder"
          , source =
              Some
                ( toMap
                    { uri =
                        Prelude.JSON.string
                          "git@github.com:cloudfoundry/eirini-private-config.git"
                    , branch = Prelude.JSON.string "master"
                    , private_key = Prelude.JSON.string privateKey
                    }
                )
          }

in  clusterState
