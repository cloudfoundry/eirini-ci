let Concourse = ../deps/concourse.dhall

in    λ(resource : Concourse.Types.Resource)
    → λ(name : Text)
    → Concourse.helpers.getStep
        Concourse.schemas.GetStep::{ resource = resource, get = Some name }
