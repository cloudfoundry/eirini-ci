let Concourse = ../../deps/concourse.dhall

in    λ(optionalLockResource : Optional Concourse.Types.Resource)
    → λ(upstream : List Text)
    → Optional/fold
        Concourse.Types.Resource
        optionalLockResource
        (List Concourse.Types.Step)
        (   λ(r : Concourse.Types.Resource)
          → [ ../../helpers/get-trigger-passed.dhall r upstream ]
        )
        ([] : List Concourse.Types.Step)
