let Concourse = ../deps/concourse.dhall

in  { ciResources : Concourse.Types.Resource
    , eiriniStagingRepo : Concourse.Types.Resource
    , stagingDownloader : Concourse.Types.Resource
    , stagingExecutor : Concourse.Types.Resource
    , stagingUploader : Concourse.Types.Resource
    , failureNotification : Optional Concourse.Types.Step
    }
