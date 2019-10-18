let Concourse = ../dhall-modules/deps/concourse.dhall

let JSON = ../dhall-modules/deps/prelude-json.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let TextTextPair = { mapKey : Text, mapValue : Text }

let TextJSONPair = { mapKey : Text, mapValue : JSON }

let textPairToJSON
    : TextTextPair → TextJSONPair
    = λ(p : TextTextPair) → p ⫽ { mapValue = Prelude.JSON.string p.mapValue }

let textMapToJSON
    : List TextTextPair → List TextJSONPair
    = Prelude.List.map TextTextPair TextJSONPair textPairToJSON

let ciResources =
        Concourse.defaults.Resource
      ⫽ { name = "ci-resources"
        , type = Concourse.Types.ResourceType.InBuilt "git"
        , source =
            Some
            ( textMapToJSON
                ( toMap
                    { uri =
                        "https://github.com/cloudfoundry-incubator/eirini-ci"
                    , branch = "((ci-resources-branch))"
                    }
                )
            )
        }

let clusterEventResource
    : Text → Text → Concourse.Types.Resource
    =   λ ( clusterName
          : Text
          )
      → λ(event : Text)
      →   Concourse.defaults.Resource
        ⫽ { name =
              "cluster-${clusterName}-staging-event-${event}"
          , type = Concourse.Types.ResourceType.InBuilt "semver"
          , source =
              Some
              ( textMapToJSON
                  ( toMap
                      { driver =
                          "git"
                      , uri =
                          "git@github.com:cloudfoundry/eirini-private-config.git"
                      , branch = "events"
                      , file = "${clusterName}-event-${event}"
                      , private_key = "((github-private-key))"
                      , initial_version = "0.1.0"
                      }
                  )
              )
          }

let clusterState =
        Concourse.defaults.Resource
      ⫽ { name = "cluster-state"
        , type = Concourse.Types.ResourceType.InBuilt "git"
        , source =
            Some
            ( textMapToJSON
                ( toMap
                    { uri =
                        "git@github.com:cloudfoundry/eirini-private-config.git"
                    , branch = "master"
                    , private_key = "((github-private-key))"
                    }
                )
            )
        }

let kubeClusterReqs =
      { ciResources = ciResources
      , clusterState = clusterState
      , clusterCreatedEvent = clusterEventResource "dhall-test" "created"
      , clusterReadyEvent = clusterEventResource "dhall-test" "ready"
      , clusterName = "dhall-test"
      , enableOPIStaging = "true"
      }

let kubeCluster = ../dhall-modules/kube-cluster.dhall kubeClusterReqs

in  kubeCluster
