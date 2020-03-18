let Concourse = ./deps/concourse.dhall

let KubeCFDeploymentRequirements = ./types/kubecf-deployment-requirements.dhall

let kubeCluster
    : KubeCFDeploymentRequirements → List Concourse.Types.GroupedJob
    =   λ(reqs : KubeCFDeploymentRequirements)
      → let smokeTestsReqs =
              { clusterName = reqs.clusterName
              , eiriniReleaseRepo = reqs.eiriniRelease
              , lockResource = reqs.lockResource
              , imageLocation = reqs.imageLocation
              , clusterState = reqs.clusterState
              , smokeTestsResource = reqs.smokeTestsResource
              , ciResources = reqs.ciResources
              , upstreamJob = "deploy-kubecf-${reqs.clusterName}"
              , skippedCats = None Text
              , creds = reqs.creds
              }

        let jobs =
              [ ./jobs/generate-kubecf-values.dhall reqs
              , ./jobs/deploy-kubecf.dhall reqs
              , ./jobs/smoke-tests.dhall smokeTestsReqs
              ]

        in  ./helpers/group-jobs.dhall [ "kubecf-${reqs.clusterName}" ] jobs

in  kubeCluster
