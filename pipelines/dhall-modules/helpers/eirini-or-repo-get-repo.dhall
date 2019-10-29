let Concourse = ../deps/concourse.dhall

in    λ(eiriniRepo : Concourse.Types.Resource)
    → λ(eiriniOrRepo : ../types/eirini-or-repo.dhall)
    → merge
        { UseEirini = eiriniRepo
        , UseRepo = λ(r : Concourse.Types.Resource) → r
        }
        eiriniOrRepo
