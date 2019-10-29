let Concourse = ../deps/concourse.dhall

in    λ(resource : Concourse.Types.Resource)
    → Concourse.helpers.getStep
        Concourse.schemas.GetStep::{ resource = resource, trigger = Some True }
