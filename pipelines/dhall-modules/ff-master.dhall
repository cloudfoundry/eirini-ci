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
                upstreamSteps
            ]

      in  ./helpers/group-jobs.dhall [ "fast-forward" ] jobs
