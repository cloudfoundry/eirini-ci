let Job = (../deps/concourse.dhall).Types.Job

in    λ(groups : List Text)
    → λ(j : Job)
    → { job = j, groups = [ "all" ] # groups }
