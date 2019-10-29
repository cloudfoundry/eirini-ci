let Concourse = ../deps/concourse.dhall

in    λ(resource : Concourse.Types.Resource)
    → λ(passed : List Text)
    → Concourse.helpers.getStep
        Concourse.schemas.GetStep::{ resource = resource, passed = Some passed }
