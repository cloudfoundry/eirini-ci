let IKSCreds = ../types/iks-creds.dhall

let GKECreds = ../types/gke-creds.dhall

in    λ(creds : ../types/creds.dhall)
    → merge
        { IKSCreds =
              λ(c : IKSCreds)
            → toMap
                { IBMCLOUD_ACCOUNT = c.account
                , IBMCLOUD_USER = c.user
                , IBMCLOUD_PASSWORD = c.password
                }
        , GKECreds =
              λ(c : GKECreds)
            → toMap
                { GCP_REGION = c.region
                , GCP_ZONE = c.zone
                , GCP_SERVICE_ACCOUNT_JSON = c.serviceAccountJSON
                }
        }
        creds
