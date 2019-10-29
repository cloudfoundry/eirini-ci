let Concourse = ../deps/concourse.dhall

in    λ(resource : Concourse.Types.Resource)
    → λ(passed : List Text)
    → Concourse.helpers.getStep
        (   Concourse.defaults.GetStep
          ⫽ { resource = resource, trigger = Some True, passed = Some passed }
        )
