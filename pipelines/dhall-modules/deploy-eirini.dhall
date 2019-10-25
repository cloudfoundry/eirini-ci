  λ(reqs : ./types/deployment-requirements.dhall)
→ [ ./jobs/deploy-uaa.dhall reqs
  , ./jobs/deploy-scf.dhall reqs
  , ./jobs/smoke-tests.dhall reqs
  ]
