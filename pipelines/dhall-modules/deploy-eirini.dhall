  λ(reqs : ./types/deployment-requirements.dhall)
→ let smokeTestsReqs =
        { clusterName = reqs.clusterName
        , eiriniReleaseRepo = reqs.eiriniReleaseRepo
        , lockResource = reqs.lockResource
        , imageLocation = reqs.imageLocation
        , clusterState = reqs.clusterState
        , smokeTestsResource = reqs.smokeTestsResource
        , ciResources = reqs.ciResources
        , upstreamJob = "deploy-scf-eirini-${reqs.clusterName}"
        , skippedCats = None Text
        }

  let jobs =
        [ ./jobs/deploy-uaa.dhall reqs
        , ./jobs/deploy-scf.dhall reqs
        , ./jobs/smoke-tests.dhall smokeTestsReqs
        ]

  in  ./helpers/group-jobs.dhall [ "deploy-${reqs.clusterName}" ] jobs
