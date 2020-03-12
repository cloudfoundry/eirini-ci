let Concourse = ../deps/concourse.dhall

let Creds = ../types/creds.dhall

let IKSCreds = ../types/iks-creds.dhall

let GKECreds = ../types/gke-creds.dhall

in    λ(clusterName : Text)
    → λ(creds : Creds)
    → λ(ciResources : Concourse.Types.Resource)
    → let iksBump =
              λ(iksCreds : IKSCreds)
            → [ Concourse.schemas.Job::{
                , name = "bump-cluster-k8s-version"
                , plan =
                    [ ../helpers/get.dhall ciResources
                    , ../tasks/bump-iks-cluster-k8s-version.dhall
                        clusterName
                        ciResources
                        iksCreds
                    ]
                }
              ]

      let bumpJob =
            merge
              { GKECreds = λ(_ : GKECreds) → [] : List Concourse.Types.Job
              , IKSCreds = iksBump
              }
              creds

      in  ../helpers/group-jobs.dhall [ "bump-cluster-k8s-version" ] bumpJob
