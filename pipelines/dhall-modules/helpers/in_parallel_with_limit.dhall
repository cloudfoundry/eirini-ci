let Prelude = ../deps/prelude.dhall

let Concourse = ../deps/concourse.dhall

let typeFixSteps
    :   ∀(T : Type)
      → Concourse.Types.StepConstructors T
      → List Concourse.Types.Step
      → List T
    =   λ(T : Type)
      → λ(constructors : Concourse.Types.StepConstructors T)
      → Prelude.List.map
          Concourse.Types.Step
          T
          (λ(s : Concourse.Types.Step) → s T constructors)

in    λ(limit : Natural)
    → λ(parallelSteps : List Concourse.Types.Step)
    → λ(Step : Type)
    → λ(constructors : Concourse.Types.StepConstructors Step)
    → let config =
            (Concourse.Types.InParallelStep Step).Config
              { steps = typeFixSteps Step constructors parallelSteps
              , limit = Some limit
              , fail_fast = None Bool
              }

      in  constructors.in_parallel config (Concourse.defaults.StepHooks Step)
