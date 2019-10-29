let Concourse = ../deps/concourse.dhall

let get
    : Concourse.Types.Resource → Concourse.Types.Step
    =   λ(resource : Concourse.Types.Resource)
      → Concourse.helpers.getStep
          (Concourse.defaults.GetStep ⫽ { resource = resource })

in  get
