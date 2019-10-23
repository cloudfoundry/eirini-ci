  λ(reqs : ./deployment-requirements.dhall)
→ [ ./jobs/deploy-uaa.dhall reqs, ./jobs/deploy-scf.dhall reqs ]
