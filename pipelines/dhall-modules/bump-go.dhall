  λ(reqs : ./types/bump-go-requirements.dhall)
→ [ ./jobs/bump-go-packages.dhall reqs, ./jobs/merge-go-bump.dhall reqs ]
