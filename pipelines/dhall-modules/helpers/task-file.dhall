let Concourse = ../deps/concourse.dhall

let taskFile
    : Concourse.Types.Resource → Text → Concourse.Types.TaskSpec
    =   λ(ciResources : Concourse.Types.Resource)
      → λ(taskName : Text)
      → Concourse.Types.TaskSpec.File
          "${ciResources.name}/tasks/${taskName}/task.yml"

in  taskFile
