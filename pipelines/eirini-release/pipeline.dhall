let Concourse = ../dhall-modules/deps/concourse.dhall

let Prelude = ../dhall-modules/deps/prelude.dhall

let iksCredsInputs =
      { account = "((ibmcloud-account))"
      , password = "((ibmcloud-password))"
      , user = "((ibmcloud-user))"
      }

let gkeCredsInputs =
      { serviceAccountJSON = "((gcp-service-account-json))"
      , dnsServiceAccountJSON = "((gcp-dns-service-account-json))"
      }

let inputs =
      { githubPrivateKey = "((github-private-key))"
      , eiriniCIBranch = "((ci-resources-branch))"
      , worldName = "((world-name))"
      , eiriniBranch = "((eirini-branch))"
      , eiriniReleaseBranch = "((eirini-release-branch))"
      , eiriniReleasePrivateKey = "((eirini-release-repo-key))"
      , dockerhubUser = "((dockerhub-user))"
      , dockerhubPassword = "((dockerhub-password))"
      , storageClass = "((storage_class))"
      , gcsJSONKey = "((gcs-json-key))"
      , clusterAdminPassword = "((cluster_admin_password))"
      , uaaAdminClientSecret = "((uaa_admin_client_secret))"
      , natsPassword = "((nats_password))"
      , diegoCellCount = "((diego-cell-count))"
      }

let iksCreds = (../dhall-modules/types/creds.dhall).IKSCreds iksCredsInputs

let withOpiDeploymentReqs =
      { worldName = inputs.worldName
      , clusterName = "dhall-with-opi"
      , enableOpiStaging = "true"
      , storageClass = inputs.storageClass
      , eiriniCIBranch = inputs.eiriniCIBranch
      , eiriniReleaseBranch = inputs.eiriniReleaseBranch
      , creds = iksCreds
      , stateGitHubPrivateKey = inputs.githubPrivateKey
      , clusterAdminPassword = inputs.clusterAdminPassword
      , uaaAdminClientSecret = inputs.uaaAdminClientSecret
      , natsPassword = inputs.natsPassword
      , diegoCellCount = inputs.diegoCellCount
      , isFreshini = False
      }

let freshiniDeploymentReqs =
      { worldName = inputs.worldName
      , clusterName = "dhall-freshini"
      , enableOpiStaging = "true"
      , storageClass = inputs.storageClass
      , eiriniCIBranch = inputs.eiriniCIBranch
      , eiriniReleaseBranch = inputs.eiriniReleaseBranch
      , creds = iksCreds
      , stateGitHubPrivateKey = inputs.githubPrivateKey
      , clusterAdminPassword = inputs.clusterAdminPassword
      , uaaAdminClientSecret = inputs.uaaAdminClientSecret
      , natsPassword = inputs.natsPassword
      , diegoCellCount = inputs.diegoCellCount
      , isFreshini = True
      }

let gkeCreds = (../dhall-modules/types/creds.dhall).GKECreds gkeCredsInputs

let gkeDeploymentReqs =
      { worldName = inputs.worldName
      , clusterName = "dhall-gkerini"
      , enableOpiStaging = "true"
      , eiriniCIBranch = inputs.eiriniCIBranch
      , eiriniReleaseBranch = inputs.eiriniReleaseBranch
      , storageClass = "missing"
      , creds = gkeCreds
      , stateGitHubPrivateKey = inputs.githubPrivateKey
      , clusterAdminPassword = inputs.clusterAdminPassword
      , uaaAdminClientSecret = inputs.uaaAdminClientSecret
      , natsPassword = inputs.natsPassword
      , diegoCellCount = inputs.diegoCellCount
      , isFreshini = False
      }

let clusterNames =
      [ gkeDeploymentReqs.clusterName
      , freshiniDeploymentReqs.clusterName
      , withOpiDeploymentReqs.clusterName
      ]

let ffMasterReqs =
      { eiriniCIBranch = inputs.eiriniCIBranch
      , eiriniReleaseBranch = inputs.eiriniReleaseBranch
      , eiriniReleasePrivateKey = inputs.eiriniReleasePrivateKey
      , clusterNames = clusterNames
      }

let withOpiEnvironment = ./set-up-ci-environment.dhall withOpiDeploymentReqs

let freshiniEnvironment = ./set-up-ci-environment.dhall freshiniDeploymentReqs

let gkeEnvironment = ./set-up-ci-environment.dhall gkeDeploymentReqs

let ffMasterModule = ../dhall-modules/ff-master.dhall ffMasterReqs

in  Prelude.List.concat
      Concourse.Types.Job
      [ withOpiEnvironment
      , gkeEnvironment
      , freshiniEnvironment
      , ffMasterModule
      ]
