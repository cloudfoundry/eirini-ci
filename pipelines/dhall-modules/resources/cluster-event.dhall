let Concourse = ../deps/concourse.dhall

let Prelude = ../deps/prelude.dhall

let clusterEventResource
    : Text → Text → Text → Concourse.Types.Resource
    =   λ(clusterName : Text)
      → λ(event : Text)
      → λ(privateKey : Text)
      →   Concourse.defaults.Resource
        ⫽ { name = "cluster-${clusterName}-staging-event-${event}"
          , type = Concourse.Types.ResourceType.InBuilt "semver"
          , icon = Some "check-decagram"
          , source =
              Some
                ( toMap
                    { driver = Prelude.JSON.string "git"
                    , uri =
                        Prelude.JSON.string
                          "git@github.com:cloudfoundry/eirini-private-config.git"
                    , branch = Prelude.JSON.string "events"
                    , file = Prelude.JSON.string "${clusterName}-event-${event}"
                    , private_key = Prelude.JSON.string privateKey
                    , initial_version = Prelude.JSON.string "0.1.0"
                    }
                )
          }

in  clusterEventResource
