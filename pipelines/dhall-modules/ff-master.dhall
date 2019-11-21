let Prelude = ./deps/prelude.dhall

in    λ(reqs : ./types/ff-master-requirements.dhall)
    → let eiriniReleaseRepo =
            ./resources/eirini-release.dhall reqs.eiriniReleaseBranch

      let eiriniReleaseMasterRepo =
            ./resources/eirini-release-master.dhall reqs.githubPrivateKey

      let upstreamSteps =
            Prelude.List.map
              Text
              Text
              (λ(clusterName : Text) → "run-core-cats-${clusterName}")
              reqs.clusterNames

      in  [ ./jobs/fast-forward-master-release.dhall
              eiriniReleaseRepo
              eiriniReleaseMasterRepo
              upstreamSteps
          ]
