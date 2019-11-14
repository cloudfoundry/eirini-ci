let IKSCreds = ./iks-creds.dhall

let GKECreds = ./gke-creds.dhall

in  < IKSCreds : IKSCreds | GKECreds : GKECreds >
