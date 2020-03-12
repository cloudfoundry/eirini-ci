let Concourse = ../deps/concourse.dhall

let taskFile
    : Concourse.Types.Resource → Text → Concourse.Types.TaskSpec
    =   λ(ciResources : Concourse.Types.Resource)
      → λ(taskPath : Text)
      → Concourse.Types.TaskSpec.File
          "${ciResources.name}/tasks/${taskPath}/task.yml"

in  taskFile
