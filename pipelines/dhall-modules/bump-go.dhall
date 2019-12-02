  λ(reqs : ./types/bump-go-requirements.dhall)
→ let bumpGoJob = ./jobs/bump-go-packages.dhall reqs

  let fastForwardJob = ./jobs/merge-go-bump.dhall reqs

  in  [ ./helpers/group-job.dhall [ "bump-go" ] bumpGoJob
      , ./helpers/group-job.dhall [ "fast-forward" ] fastForwardJob
      ]
