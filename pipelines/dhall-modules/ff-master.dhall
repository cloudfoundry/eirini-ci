let Prelude = ./deps/prelude.dhall

in    λ(reqs : ./types/ff-master-requirements.dhall)
    → let upstreamSteps =
            Prelude.List.map
              Text
              Text
              (λ(clusterName : Text) → "run-core-cats-${clusterName}")
              reqs.clusterNames

      let jobs =
            [ ./jobs/fast-forward-master-release.dhall
                reqs.eiriniReleaseRepo
                reqs.writeableReleaseRepoMaster
                (upstreamSteps # [ "smoke-tests-cf4k8s" ])
            ]

      in  ./helpers/group-jobs.dhall [ "fast-forward" ] jobs
